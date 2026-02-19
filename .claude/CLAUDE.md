# ComplianceAsCode/content

## Project Overview

This repository produces SCAP data streams, Ansible playbooks, Bash scripts, and other artifacts for compliance scanning and remediation.

Each supported operating system or platform is called a **product**. To see the full list of products, check the subdirectories under `products/` — each subdirectory name is a product ID (e.g., `rhel9`, `ocp4`, `ubuntu2404`). Product-specific configuration lives in `products/<product>/product.yml`.

## Repository Structure

```
applications/openshift/    # OCP4 and Kubernetes rules, organized by component
linux_os/guide/            # Linux rules (RHEL, RHCOS, etc.), organized by system area
controls/                  # Compliance framework mappings (CIS, STIG, SRG, NIST, etc.)
products/                  # Product definitions, profiles, and product-specific controls
shared/templates/          # Reusable check/remediation templates (60+ types)
shared/macros/             # Jinja2 macro files for generating OVAL, Ansible, Bash, etc.
components/                # Component definitions mapping rules to packages/groups
```

### Discovering Rule Directories

- **OCP4/Kubernetes rules** live under `applications/openshift/`, organized by component (e.g., `api-server/`, `kubelet/`, `etcd/`). Each component directory contains rule subdirectories. The rule ID prefix typically matches the component directory name with hyphens replaced by underscores (e.g., rules in `api-server/` use the `api_server_` prefix). Browse `applications/openshift/` to see all component directories.
- **Linux rules** (RHEL, RHCOS, Fedora, Ubuntu, etc.) live under `linux_os/guide/`, organized by system area (e.g., `system/`, `services/`, `auditing/`). Browse the subdirectories to find the appropriate category for a rule.
- When placing a new rule, find 2-3 existing rules with a similar prefix or topic and place the new rule alongside them.

## Rule Format

Each rule lives in its own directory. The **directory name is the rule ID**. The directory contains `rule.yml` and optionally a `tests/` subdirectory.

### `rule.yml` Fields

```yaml
documentation_complete: true          # Must be true for the rule to be built

title: 'Short descriptive title'

description: |-                        # Full description, supports HTML tags and Jinja2 macros
    Description text here.

rationale: |-                          # Why this rule matters
    Rationale text here.

severity: medium                       # low, medium, high, unknown

identifiers:                           # Product-specific CCE identifiers
    cce@ocp4: CCE-XXXXX-X
    cce@rhel9: CCE-XXXXX-X

references:                            # Compliance framework references
    cis@ocp4: 1.2.3                    # CIS benchmark section
    nist: CM-6,CM-6(1)                 # NIST 800-53 controls
    srg: SRG-APP-000516-CTR-001325     # DISA SRG ID
    stigid@rhel9: RHEL-09-XXXXXX       # STIG rule ID (product-scoped)
    nerc-cip: CIP-003-8 R6             # NERC CIP references
    pcidss: Req-2.2                    # PCI DSS requirements

ocil_clause: 'condition when rule fails'  # Used in OCIL questionnaire

ocil: |-                               # Manual check instructions
    Run the following command:
    <pre>$ oc get ...</pre>

platform: ocp4                         # Platform applicability (optional)

warnings:                              # Optional warnings section
    - general: |-
        Warning text, often includes openshift_cluster_setting macro.

template:                              # Optional - uses a shared template for checks
    name: yamlfile_value
    vars:
        ocp_data: "true"
        filepath: '/api/path/here'
        yamlpath: '.spec.field'
        values:
          - value: 'expected_value'
            operation: "pattern match"

fixtext: 'Remediation instructions'    # STIG fixtext (optional)
srg_requirement: 'SRG requirement'     # SRG requirement text (optional)
```

## Templates

Templates generate OVAL checks, Ansible playbooks, and Bash remediation scripts automatically.

### `yamlfile_value` (primary OCP4 template)

Checks values in YAML/JSON files or API responses.

```yaml
template:
    name: yamlfile_value
    vars:
        ocp_data: "true"                        # "true" for OCP API data
        filepath: '/apis/...'                   # API path or file path
        yamlpath: '.spec.config.field'          # JSONPath-like expression
        check_existence: "at_least_one_exists"  # Optional existence check
        entity_check: "at least one"            # How to evaluate multiple matches
        values:
          - value: 'expected'                   # Expected value or regex
            type: "string"                      # string, int, boolean
            operation: "pattern match"          # equals, not equal, pattern match,
                                                # greater than or equal, less than or equal
            entity_check: "at least one"        # Per-value entity check
```

### `file_permissions` (RHEL)

```yaml
template:
    name: file_permissions
    vars:
        filepath: /etc/cron.d/
        filemode: '0700'
```

### `shell_lineinfile` (RHEL)

```yaml
template:
    name: shell_lineinfile
    vars:
        path: '/etc/sysconfig/sshd'
        parameter: 'SSH_USE_STRONG_RNG'
        value: '32'
        datatype: int                       # Optional
        no_quotes: 'true'                   # Optional
```

### `sysctl` (RHEL)

```yaml
template:
    name: sysctl
    vars:
        sysctlvar: net.ipv6.conf.all.accept_ra
        datatype: int
```

### `service_enabled` / `service_disabled` (RHEL)

```yaml
template:
    name: service_disabled
    vars:
        servicename: avahi
```

### `package_installed` / `package_removed` (RHEL)

```yaml
template:
    name: package_removed
    vars:
        pkgname: avahi
        pkgname@ubuntu2204: avahi-daemon    # Platform-specific overrides
```

## Common Jinja2 Macros

Used in rule descriptions, OCIL, fixtext, and warnings fields:

- `{{{ openshift_cluster_setting("/api/path") }}}` - Generates OCP API check instructions
- `{{{ openshift_filtered_cluster_setting({'/api/path': jqfilter}) }}}` - Filtered API check with jq
- `{{{ openshift_filtered_path('/api/path', jqfilter) }}}` - Generates filtered filepath for templates
- `{{{ full_name }}}` - Expands to product full name (e.g., "Red Hat Enterprise Linux 9")
- `{{{ xccdf_value("var_name") }}}` - References an XCCDF variable
- `{{{ weblink("https://...") }}}` - Creates an HTML link
- `{{{ describe_service_disable(service="name") }}}` - Standard service disable description
- `{{{ describe_service_enable(service="name") }}}` - Standard service enable description
- `{{{ describe_file_permissions(file="/path", perms="0700") }}}` - File permission description
- `{{{ describe_sysctl_option_value(sysctl="key", value="val") }}}` - Sysctl description
- `{{{ complete_ocil_entry_sysctl_option_value(sysctl="key", value="val") }}}` - Full OCIL for sysctl
- `{{{ complete_ocil_entry_package(package="name") }}}` - Full OCIL for package check
- `{{{ fixtext_package_removed("name") }}}` - Fixtext for package removal
- `{{{ fixtext_sysctl("key", "value") }}}` - Fixtext for sysctl setting
- `{{{ fixtext_directory_permissions(file="/path", mode="0600") }}}` - Fixtext for dir permissions

## Control File Format

Control files map compliance framework requirements to rules. They exist in two layouts:

### Single-file format

```yaml
# controls/stig_rhel9.yml (or products/rhel9/controls/stig_rhel9.yml)
policy: 'Red Hat Enterprise Linux 9 STIG'
title: 'DISA STIG for RHEL 9'
id: stig_rhel9
source: https://www.cyber.mil/stigs/downloads/
version: V2R7
reference_type: stigid
product: rhel9

levels:
    - id: high
    - id: medium
    - id: low

controls:
    - id: RHEL-09-211010
      levels:
          - high
      title: RHEL 9 must be a vendor-supported release.
      rules:
          - installed_OS_is_vendor_supported
      status: automated
```

### Split-directory format

```
controls/cis_ocp.yml          # Top-level: policy, title, id, levels
controls/cis_ocp/             # Directory with section files
    section-1.yml             # Controls for section 1
    section-2.yml             # Controls for section 2
    ...
```

Section files contain nested controls:

```yaml
controls:
    - id: '1'
      title: Control Plane Components
      controls:
          - id: '1.1'
            title: Master Node Configuration Files
            controls:
                - id: 1.1.1
                  title: Ensure that the API server pod specification...
                  status: automated
                  rules:
                      - file_permissions_kube_apiserver
                  levels:
                      - level_1
```

### Control entry fields

- `id` - Control identifier (e.g., "RHEL-09-211010", "1.2.3")
- `title` - Human-readable title
- `levels` - Applicable compliance levels
- `rules` - List of rule IDs that satisfy this control
- `status` - `automated`, `manual`, `inherently met`, `does not meet`, `pending`, `not applicable`
- `notes` - Optional notes explaining status or implementation

## Profile File Format

Profiles select which rules apply to a product. Located at `products/<product>/profiles/<name>.profile`.

```yaml
documentation_complete: true
title: 'Profile Title'
description: |-
    Profile description text.
platform: ocp4
metadata:
    version: V2R7
    SMEs:
        - github_username

selections:
    - control_id:all              # Include all rules from a control file
    - rule_id                     # Include a specific rule
    - '!rule_id'                  # Exclude a specific rule
    - var_name=value              # Set a variable value
```

Common selection patterns:
- `stig_rhel9:all` - Pull in all rules from the stig_rhel9 control file
- `cis_ocp:all` - Pull in all rules from the cis_ocp control file
- `!audit_rules_immutable_login_uids` - Exclude a specific rule
- `var_sshd_set_keepalive=1` - Set a variable

## Build Instructions

```bash
# Build a single product (full build)
./build_product ocp4

# Build data stream only (faster, skips guides and tables)
./build_product ocp4 --datastream-only

# Build with only specific rules (fastest, for testing individual rules)
./build_product ocp4 --datastream-only --rule-id api_server_tls_security_profile
```

Build output goes to `build/`. The data stream file is at:
`build/ssg-<product>-ds.xml`

## Guidelines for Claude

1. **Always show proposals before making changes.** Present the full content of any new or modified file and wait for explicit approval.
2. **Follow existing patterns.** Before creating a rule, find 2-3 similar existing rules and match their style exactly.
3. **Check for duplicates.** Before creating a new rule, search for existing rules that might already cover the requirement.
4. **Use the correct directory.** Find existing rules with the same prefix to determine the right directory. When in doubt, browse `applications/openshift/` or `linux_os/guide/` to find the appropriate component or category.
5. **Preserve formatting.** This project uses consistent YAML formatting. Match the indentation and style of surrounding content.
6. **Don't invent references.** Only include reference IDs (CCE, CIS, STIG, SRG, NIST) that the user provides or that exist in source documents.
