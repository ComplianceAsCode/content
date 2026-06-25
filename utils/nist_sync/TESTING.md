# Testing Gemara NIST 800-53 Export with complyctl

End-to-end guide for validating the Gemara export against complyctl.
Tests all three NIST baselines (Low, Moderate, High) using the `nist_800_53` XCCDF profile.

The recommended approach uses a RHEL9 Vagrant VM so that OpenSCAP evaluates actual system
state and compliance findings are meaningful. See the [Vagrant workflow](#vagrant-workflow-realistic-os-scanning) section.

---

## Prerequisites

### 1. Python dependencies

```bash
pip install ruamel.yaml
source ./.pyenv.sh        # adds ssg/ modules to PYTHONPATH
```

### 2. SCAP data stream

The data stream provides the XCCDF rules that complyctl tailors and OpenSCAP evaluates.

```bash
# Option A — install from RPM (Fedora/RHEL host)
sudo dnf install scap-security-guide

# Option B — build from source (this repo)
./build_product rhel9 --datastream
sudo mkdir -p /usr/share/xml/scap/ssg/content
sudo cp build/ssg-rhel9-ds.xml /usr/share/xml/scap/ssg/content/
```

Verify: `/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml` exists.

### 3. OSCAL data (for GuidanceCatalog generation)

The OSCAL catalog is needed to enrich controls with NIST prose. It is gitignored (10 MB).

```bash
python3 utils/nist_sync/download_oscal.py
```

### 4. complyctl binary

```bash
curl -L https://github.com/complytime/complyctl/releases/download/v1.0.0-alpha.0/complyctl_linux_x86_64.tar.gz \
    | tar -xz -C ~/bin complyctl
chmod +x ~/bin/complyctl
complyctl version
```

### 5. complyctl-provider-openscap

```bash
mkdir -p ~/.complytime/providers
# Download from the complytime releases or build from source
# Place the binary at: ~/.complytime/providers/complyctl-provider-openscap
chmod +x ~/.complytime/providers/complyctl-provider-openscap
```

### 6. oras CLI

Used to push split-layer OCI bundles to the VM's OCI registry.

```bash
# Fedora/RHEL
sudo dnf install oras

# Or download from https://oras.land
```

---

## Step-by-step walkthrough

Follow these steps to understand exactly what each phase does.

### Step 1 — Generate Gemara artifacts

Reads the NIST 800-53 control files for rhel9 and produces three YAML files.

```bash
source ./.pyenv.sh

python3 utils/nist_sync/export_to_gemara.py \
    --products rhel9 \
    --output-dir build/gemara \
    --data-dir utils/nist_sync/data \
    --validate
```

Output:
```
build/gemara/
  rhel9/
    control_catalog.yaml   # NIST controls → CaC rule IDs  (ControlCatalog)
    rules_mapping.yaml     # rule IDs → NIST controls       (MappingDocument)
  guidance_catalog.yaml    # NIST prose / objectives        (GuidanceCatalog, needs OSCAL)
```

Verify: `python3 utils/nist_sync/test_gemara_export.py --products rhel9`

### Step 2 — Build and push per-baseline OCI bundles

One bundle per baseline. Each contains a Gemara Policy filtered to that baseline's rules.

```bash
for baseline in low moderate high; do
    python3 utils/nist_sync/generate_complyctl_bundle.py \
        --product rhel9 \
        --gemara-dir build/gemara \
        --output-dir "build/gemara-bundle/rhel9/${baseline}" \
        --baseline "$baseline" \
        --base-profile nist_800_53 \
        --registry 127.0.0.1:5500 \
        --tag "nist-800-53-rev5-rhel9-${baseline}:latest" \
        --push --verbose

    echo "Pushed ${baseline} bundle:"
    grep -c "requirement-id:" "build/gemara-bundle/rhel9/${baseline}/rhel9_policy.yaml" | \
        xargs echo "  assessment-plans:"
done
```

Why `nist_800_53` as the base profile?
The profile at `products/rhel9/profiles/nist_800_53.profile` selects **all** NIST-mapped rules
(`nist_800_53:all`). complyctl uses it as the tailoring base and then restricts evaluation to
only the rules present in the Policy's assessment-plans.

### Step 3 — Verify bundle contents

```bash
# Inspect the policy for a baseline
python3 -c "
from ruamel.yaml import YAML
y = YAML()
p = y.load(open('build/gemara-bundle/rhel9/moderate/rhel9_policy.yaml'))
plans = p['adherence']['assessment-plans']
print(f'moderate: {len(plans)} rules')
print('First 5:', [ap[\"id\"] for ap in plans[:5]])
"
```

### Step 4 — Interpret results

The scan results are in ARF (Assessment Results Format). Use the MappingDocument to
trace rule results back to NIST controls:

```bash
# Which NIST controls does a passing rule satisfy?
python3 - << 'EOF'
from ruamel.yaml import YAML
y = YAML()
mapping = y.load(open("build/gemara/rhel9/rules_mapping.yaml"))

rule = "accounts_tmout"
controls = [
    m["source"] for m in mapping["mappings"]
    if any(t["entry-id"] == rule for t in m.get("targets", []))
]
print(f"{rule} → NIST controls: {controls}")
EOF
```

---

## Architecture notes

### Why `nist_800_53` profile as the base?

complyctl uses the base profile as the starting point for XCCDF tailoring. It then enables only
the rules listed in the Policy's assessment-plans. The `nist_800_53.profile` selects all
NIST-mapped rules (`nist_800_53:all`), ensuring every assessment-plan rule is available for
tailoring regardless of which baseline is being tested.

### Why `datastream:` in complytime.yaml?

Without an explicit datastream path, the OpenSCAP provider reads `ID_LIKE` from
`/etc/os-release` to pick the data stream. On some systems or containers this can resolve
to the wrong file. The `datastream:` variable bypasses auto-detection and pins the path.

### Per-baseline rule counts (rhel9)

| Baseline | Rules | Notes |
|----------|-------|-------|
| low      | 383   | All rules with any NIST mapping |
| moderate | 22    | Rules that first appear at moderate level |
| high     | 4     | Rules that first appear at high level |

Counts vary with the state of NIST control mappings in the product control files.

---

## Vagrant workflow (realistic OS scanning)

Mirrors the [complytime-demos](https://github.com/complytime/complytime-demos) pattern:
a RHEL9 VM runs complyctl against its own OS state, giving compliance findings that reflect
a real system rather than a minimal UBI container.

```
Host (your laptop / CI machine)
  ├── export_to_gemara.py               — generates Gemara YAML artifacts
  ├── generate_complyctl_bundle.py      — builds per-baseline Policy bundle
  ├── oras                              — pushes bundle to VM_IP:5500 (HOST → VM)
  └── Ansible                           — orchestrates everything below

VM (generic/rhel9 via Vagrant)
  ├── openscap-scanner                  — evaluates XCCDF rules against the real OS
  ├── ssg-rhel9-ds.xml                  — from scap-security-guide RPM (or copied from host)
  ├── registry (distribution binary)   — OCI registry at 0.0.0.0:5500 (systemd service)
  └── complyctl                         — fetches from localhost:5500, runs scan

Note: podman is NOT installed in the VM (containers-common conflicts with redhat-release-9.3
on generic/rhel9 boxes). The distribution/distribution registry binary is used instead.
```

### Prerequisites

| Tool | Install |
|------|---------|
| Vagrant | https://developer.hashicorp.com/vagrant/install |
| vagrant-libvirt plugin | `vagrant plugin install vagrant-libvirt` |
| Ansible ≥ 2.14 | `pip install ansible` |
| complyctl binary | see [§4 above](#4-complyctl-binary) |
| complyctl-provider-openscap | see [§5 above](#5-complyctl-provider-openscap) |
| Python deps | `pip install ruamel.yaml` |

VirtualBox can be used instead of libvirt — Vagrant auto-detects the available provider.

### Step 1 — Start the VM

```bash
cd utils/nist_sync/vagrant
vagrant up

# Vagrant triggers populate_inventory.sh automatically after boot.
# Verify the inventory was written:
cat ansible/inventory.ini
```

If the trigger did not run (e.g. permission issue), run it manually:

```bash
cd utils/nist_sync/vagrant
bash populate_inventory.sh
```

### Step 2 — One-time setup

Install complyctl, the provider, and start the distribution registry binary inside the VM.

```bash
cd utils/nist_sync

ansible-playbook -i ansible/inventory.ini ansible/setup.yml \
    -e complyctl_bin=/tmp/complyctl \
    -e provider_bin=~/.complytime/providers/complyctl-provider-openscap
```

`setup.yml` also copies `build/ssg-rhel9-ds.xml` to the VM if `scap-security-guide` is not
available from the VM's package repos.

### Step 3 — Run scans (all baselines)

```bash
cd utils/nist_sync

ansible-playbook -i ansible/inventory.ini ansible/scan.yml
```

What happens per baseline (low / moderate / high):

1. **Host**: exports Gemara artifacts (`export_to_gemara.py`)
2. **Host**: generates a filtered Policy bundle (`generate_complyctl_bundle.py --push`)
   and pushes it to `VM_IP:5500` via `oras`
3. **VM**: writes `complytime.yaml` pointing to `localhost:5500`
4. **VM**: `complyctl get` pulls bundle metadata
5. **VM**: `complyctl generate` builds a tailored XCCDF profile
6. **VM**: `complyctl scan` runs OpenSCAP against the live RHEL9 OS
7. **Host**: results fetched to `build/complyctl-results/rhel9/{baseline}/`

To test a single baseline:

```bash
ansible-playbook -i ansible/inventory.ini ansible/scan.yml -e baseline=moderate
```

### Step 4 — Inspect results

```bash
# ARF result (OpenSCAP native format)
ls build/complyctl-results/rhel9/moderate/

# Count pass/fail at the rule level
python3 - << 'EOF'
import xml.etree.ElementTree as ET
tree = ET.parse("build/complyctl-results/rhel9/moderate/arf.xml")
ns = {"xccdf": "http://checklists.nist.gov/xccdf/1.2"}
rules = tree.findall(".//xccdf:rule-result", ns)
summary = {}
for r in rules:
    result = r.find("xccdf:result", ns)
    if result is not None:
        summary[result.text] = summary.get(result.text, 0) + 1
for outcome, count in sorted(summary.items()):
    print(f"  {outcome:20s}: {count}")
EOF

# Trace a rule result back to NIST controls
python3 - << 'EOF'
from ruamel.yaml import YAML
y = YAML()
mapping = y.load(open("build/gemara/rhel9/rules_mapping.yaml"))
rule = "accounts_tmout"
controls = [
    m["source"] for m in mapping["mappings"]
    if any(t["entry-id"] == rule for t in m.get("targets", []))
]
print(f"{rule} → NIST controls: {controls}")
EOF
```

### Teardown

```bash
cd utils/nist_sync/vagrant
vagrant halt    # power off (preserves disk)
vagrant destroy # remove completely
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `0 rules matched` in scan | Wrong base profile or data stream | Verify `nist_800_53` profile exists in the data stream; build from source if needed |
| `oras push failed` | Registry not running in VM | `vagrant ssh -- sudo systemctl restart gemara-registry` |
| `guidance_catalog.yaml` missing | OSCAL data not downloaded | `python3 utils/nist_sync/download_oscal.py` |
| `complyctl: permission denied` | Binary not executable | `chmod +x /path/to/complyctl` |
| Provider not found | Wrong path | Check `~/.complytime/providers/complyctl-provider-openscap` |
| `ansible/inventory.ini` empty or stale | VM IP changed after re-provision | `cd vagrant && bash populate_inventory.sh` |
| Registry unreachable from host during push | VM firewall blocks port 5500 | `vagrant ssh -- sudo firewall-cmd --add-port=5500/tcp --permanent --zone=public && sudo firewall-cmd --reload` |
| `vagrant up` fails with libvirt errors | libvirt not running | `sudo systemctl start libvirtd` |
| `scap-security-guide` not installed on VM | Unsubscribed RHEL9 box | `setup.yml` copies `build/ssg-rhel9-ds.xml` automatically — build the data stream first: `./build_product rhel9 -d` |
