#!/usr/bin/env python3
"""
Generate a complyctl-compatible OCI bundle from Gemara export artifacts.

This script:
  1. Reads a Gemara ControlCatalog produced by export_to_gemara.py
  2. Generates a Gemara Policy YAML with full XCCDF rule IDs in assessment-plans
     (complyctl passes requirement-id directly to the OpenSCAP provider as an XCCDF rule ID)
  3. Optionally packages everything into a split-layer OCI artifact using oras and
     pushes it to a local OCI registry

Usage:
    # Generate policy YAML only (no registry needed)
    python3 utils/nist_sync/generate_complyctl_bundle.py --product rhel9

    # Package and push to a local registry
    python3 utils/nist_sync/generate_complyctl_bundle.py --product rhel9 --push

    # Use a specific rule subset (baseline filter)
    python3 utils/nist_sync/generate_complyctl_bundle.py --product rhel9 --baseline moderate

Prerequisites for --push:
    - oras CLI (https://oras.land) on PATH
    - A running OCI registry at 127.0.0.1:5000 (start with:
        podman run -d -p 5000:5000 --name registry docker.io/library/registry:2)
    - complyctl binary on PATH or in ~/.complytime/
"""

import argparse
import io
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    from ruamel.yaml import YAML
except ImportError:
    sys.stderr.write("Error: ruamel.yaml is required. Install with: pip install ruamel.yaml\n")
    sys.exit(1)

_SCRIPT_DIR = Path(__file__).parent
_REPO_ROOT = _SCRIPT_DIR.parent.parent
_GEMARA_VERSION = "1.1.0"

# CaC XCCDF rule ID prefix
_XCCDF_PREFIX = "xccdf_org.ssgproject.content_rule_"

# OCI media types for complyctl v1.0.0-alpha.0 (go-gemara v0.0.1 split-layer format)
_MEDIA_TYPE_POLICY = "application/vnd.gemara.policy.v1+yaml"
_MEDIA_TYPE_CATALOG = "application/vnd.gemara.catalog.v1+yaml"
_ARTIFACT_TYPE = "application/vnd.gemara.bundle.v1"

_PRODUCT_FULL_NAMES = {
    "rhel8": "Red Hat Enterprise Linux 8",
    "rhel9": "Red Hat Enterprise Linux 9",
    "rhel10": "Red Hat Enterprise Linux 10",
}


def _now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _yaml():
    y = YAML()
    y.default_flow_style = False
    y.allow_unicode = True
    y.width = 120
    return y


def load_yaml(path):
    y = _yaml()
    with open(path) as f:
        return y.load(f)


def dump_yaml(data, path):
    y = _yaml()
    buf = io.StringIO()
    y.dump(data, buf)
    path.write_text(buf.getvalue(), encoding="utf-8")


def extract_rules_from_catalog(catalog, baseline=None):
    """
    Extract unique XCCDF rule IDs from a ControlCatalog.

    Returns a list of (rule_id, nist_control_ids) tuples where:
      - rule_id is the raw CaC rule ID (e.g. 'accounts_tmout')
      - nist_control_ids is the list of NIST controls that reference this rule
    """
    # Build control's applicability-groups for baseline filtering
    meta = catalog.get("metadata", {})
    app_groups = {g["id"] for g in meta.get("applicability-groups", [])}

    rule_to_controls = {}
    for ctrl in catalog.get("controls", []):
        ctrl_id = ctrl.get("id", "")
        ctrl_state = ctrl.get("state", "")

        # Skip deprecated/retired controls
        if ctrl_state in ("Deprecated", "Retired"):
            continue

        # Baseline filter: check if control's requirements have the requested baseline
        if baseline:
            any_in_baseline = False
            for req in ctrl.get("assessment-requirements", []):
                if baseline in req.get("applicability", []):
                    any_in_baseline = True
                    break
            if not any_in_baseline:
                continue

        for req in ctrl.get("assessment-requirements", []):
            req_id = req.get("id", "")
            # Skip placeholder and variable requirements
            if req_id.endswith("--no-automated-check"):
                continue
            text = req.get("text", "")
            if text.startswith("Variable '"):
                continue

            # Extract rule_id from compound ID: "{control_id}--{rule_id}"
            if "--" in req_id:
                rule_id = req_id.split("--", 1)[1]
            else:
                continue

            if rule_id not in rule_to_controls:
                rule_to_controls[rule_id] = []
            if ctrl_id not in rule_to_controls[rule_id]:
                rule_to_controls[rule_id].append(ctrl_id)

    return sorted(rule_to_controls.items())


def generate_policy(product, catalog_id, rules_with_controls):
    """
    Build a Gemara Policy YAML dict with XCCDF rule IDs in assessment-plans.

    requirement-id uses the full XCCDF rule ID so that the complyctl OpenSCAP
    provider can pass it directly to 'oscap xccdf eval --rule <id>'.
    """
    full_name = _PRODUCT_FULL_NAMES.get(product, product.upper())
    policy_id = f"nist-800-53-rev5-{product}-policy"

    assessment_plans = []
    for rule_id, nist_controls in rules_with_controls:
        xccdf_id = f"{_XCCDF_PREFIX}{rule_id}"
        assessment_plans.append({
            "id": f"ap-{rule_id}",
            # complyctl passes this directly to the OpenSCAP provider as the XCCDF rule ID
            "requirement-id": xccdf_id,
            "frequency": "on-demand",
            "evaluation-methods": [
                {
                    "id": "openscap-automated",
                    "type": "Behavioral",
                    "mode": "Automated",
                }
            ],
        })

    return {
        "title": f"NIST SP 800-53 Rev 5 for {full_name}",
        "metadata": {
            "id": policy_id,
            "type": "Policy",
            "gemara-version": _GEMARA_VERSION,
            "description": (
                f"Automated evaluation policy for NIST SP 800-53 Rev 5 on {full_name}, "
                "using ComplianceAsCode rules. requirement-id values are XCCDF rule IDs "
                "passed directly to the OpenSCAP provider."
            ),
            "author": {
                "id": "complianceascode",
                "name": "ComplianceAsCode Project",
                "type": "Human",
                "uri": "https://github.com/ComplianceAsCode/content",
            },
            "date": _now_iso(),
            "mapping-references": [
                {
                    "id": catalog_id,
                    "title": f"NIST SP 800-53 Rev 5 Control Catalog for {product.upper()}",
                    "version": "Revision 5",
                    "url": "https://github.com/ComplianceAsCode/content",
                }
            ],
        },
        "contacts": {
            "responsible": [{"name": "System Administrator"}],
            "accountable": [{"name": "Security Team"}],
        },
        "scope": {
            "in": {
                "technologies": [full_name],
            }
        },
        "imports": {
            "catalogs": [
                {"reference-id": catalog_id}
            ]
        },
        "adherence": {
            "evaluation-methods": [
                {
                    "id": "openscap-automated",
                    "type": "Behavioral",
                    "mode": "Automated",
                    "description": "OpenSCAP automated compliance evaluation",
                    "executor": {
                        "id": "openscap",
                        "name": "OpenSCAP",
                        "type": "Software",
                    },
                }
            ],
            "assessment-plans": assessment_plans,
        },
    }


def generate_complytime_yaml(product, registry_url, bundle_tag):
    """Generate a ~/.complytime/complytime.yaml for this bundle.

    Format expected by complyctl v1.0.0-alpha.0. The http:// prefix triggers
    PlainHTTP mode in the OCI client (checked by string prefix in the source).
    """
    policy_id = f"nist-800-53-rev5-{product}"
    profile_id = f"nist-800-53-rev5-{product}-policy"
    # complyctl appends :latest by default — strip any existing tag to avoid "latest:latest"
    bundle_ref = bundle_tag.split(":")[0]
    return f"""\
# complytime.yaml — complyctl v1.0.0-alpha.0 workspace configuration
policies:
  - url: {registry_url}/{bundle_ref}
    id: {policy_id}

targets:
  - id: local
    policies:
      - {policy_id}
    variables:
      profile: {profile_id}
"""


def push_bundle(policy_path, catalog_path, registry_url, tag, verbose=False):
    """Package and push split-layer OCI bundle using oras."""
    oras = shutil.which("oras")
    if not oras:
        sys.stderr.write("ERROR: 'oras' not found on PATH. Install from https://oras.land\n")
        return False

    # oras reference must not include the http(s):// scheme — that's handled by --plain-http
    registry_host = registry_url.removeprefix("http://").removeprefix("https://")

    if verbose:
        print(f"  Pushing to {registry_host}/{tag}")

    # oras push with two layers, each with a distinct media type.
    # complyctl v1.0.0-alpha.0 (go-gemara v0.0.1) uses split-layer detection:
    #   layer[mediaType=policy]  → policy file
    #   layer[mediaType=catalog] → catalog file
    # Run from the output dir so oras sees relative paths (avoids path-validation error).
    cwd = policy_path.parent
    policy_rel = policy_path.name
    catalog_rel = catalog_path.name

    cmd = [
        oras, "push",
        "--plain-http",
        f"{registry_host}/{tag}",
        f"--artifact-type={_ARTIFACT_TYPE}",
        f"{policy_rel}:{_MEDIA_TYPE_POLICY}",
        f"{catalog_rel}:{_MEDIA_TYPE_CATALOG}",
    ]

    result = subprocess.run(cmd, cwd=str(cwd), capture_output=not verbose, text=True)
    if result.returncode != 0:
        sys.stderr.write(f"ERROR: oras push failed:\n{result.stderr}\n")
        return False

    if verbose:
        print(f"  Pushed successfully: {registry_host}/{tag}")
    return True


def write_instructions(output_dir, product, registry_url, bundle_tag):
    """Write a HOWTO file with complyctl commands."""
    instructions = f"""\
# Testing the NIST 800-53 Gemara bundle with complyctl
# Generated: {_now_iso()}

## Prerequisites

1. Start a local OCI registry (if not already running):
   podman run -d -p 5000:5000 --name registry docker.io/library/registry:2

2. Ensure complyctl is on PATH:
   export PATH="$HOME/.complytime:$PATH"

3. Copy complytime.yaml to your config directory:
   cp {output_dir}/complytime.yaml ~/.complytime/complytime.yaml

## Run the tests

### Step 1: Pull the bundle
complyctl get

### Step 2: Generate tailored XCCDF (validates the Policy and provider)
complyctl generate

### Step 3: Run the scan (requires OpenSCAP installed)
complyctl scan

### Step 4: View results
complyctl report

## Bundle contents

  Policy:  {output_dir}/{product}_policy.yaml
           {len(open(f'{output_dir}/{product}_policy.yaml').readlines())} lines
           assessment-plans use XCCDF rule IDs (xccdf_org.ssgproject.content_rule_*)

  Catalog: {output_dir}/{product}_catalog.yaml (copy of build/gemara/{product}/control_catalog.yaml)
           Maps NIST controls → XCCDF rules (for traceability and reporting)

## Traceability

After the scan, use the MappingDocument to interpret results at the NIST control level:
  build/gemara/{product}/rules_mapping.yaml

Example: if 'accounts_tmout' PASSES, then NIST ac-2.5 is satisfied.
"""
    path = output_dir / "HOWTO.txt"
    path.write_text(instructions, encoding="utf-8")
    return path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate a complyctl-compatible OCI bundle from Gemara export artifacts",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--product", default="rhel9", help="Product to generate bundle for (default: rhel9)")
    parser.add_argument(
        "--gemara-dir",
        type=Path,
        default=_REPO_ROOT / "build" / "gemara",
        help="Directory containing gemara export output (default: build/gemara)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("/tmp/complyctl-bundle"),
        help="Output directory for bundle files (default: /tmp/complyctl-bundle)",
    )
    parser.add_argument(
        "--registry",
        default="127.0.0.1:5000",
        help="OCI registry host:port (default: 127.0.0.1:5000)",
    )
    parser.add_argument(
        "--tag",
        default=None,
        help="OCI tag (default: nist-800-53-rev5-{product}:latest)",
    )
    parser.add_argument(
        "--baseline",
        choices=["low", "moderate", "high"],
        default=None,
        help="Filter rules to a NIST baseline (default: all automated rules)",
    )
    parser.add_argument("--push", action="store_true", help="Push bundle to the OCI registry using oras")
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    product = args.product
    gemara_dir = args.gemara_dir
    output_dir = args.output_dir
    registry_url = f"http://{args.registry}"
    tag = args.tag or f"nist-800-53-rev5-{product}:latest"

    catalog_yaml_path = gemara_dir / product / "control_catalog.yaml"
    if not catalog_yaml_path.exists():
        sys.stderr.write(
            f"ERROR: {catalog_yaml_path} not found.\n"
            f"Run first: python3 utils/nist_sync/export_to_gemara.py --products {product}\n"
        )
        sys.exit(1)

    output_dir.mkdir(parents=True, exist_ok=True)
    baseline_note = f" (baseline: {args.baseline})" if args.baseline else " (all automated rules)"
    print(f"Generating complyctl bundle for {product}{baseline_note}")

    # Load catalog and extract rules
    print(f"  Reading {catalog_yaml_path}")
    catalog = load_yaml(catalog_yaml_path)
    catalog_id = catalog["metadata"]["id"]
    rules_with_controls = extract_rules_from_catalog(catalog, baseline=args.baseline)
    print(f"  Found {len(rules_with_controls)} unique XCCDF rules")

    # Generate Policy YAML
    policy = generate_policy(product, catalog_id, rules_with_controls)
    policy_path = output_dir / f"{product}_policy.yaml"
    dump_yaml(policy, policy_path)
    print(f"  Wrote Policy:  {policy_path}")
    print(f"    {len(rules_with_controls)} assessment-plans with XCCDF rule IDs")

    # Copy catalog (complyctl needs it in the bundle for traceability)
    catalog_copy_path = output_dir / f"{product}_catalog.yaml"
    import shutil
    shutil.copy2(catalog_yaml_path, catalog_copy_path)
    print(f"  Wrote Catalog: {catalog_copy_path}")

    # Generate complytime.yaml
    complytime_yaml = generate_complytime_yaml(product, registry_url, tag)
    complytime_path = output_dir / "complytime.yaml"
    complytime_path.write_text(complytime_yaml, encoding="utf-8")
    print(f"  Wrote complytime.yaml: {complytime_path}")

    # Write HOWTO
    howto_path = write_instructions(output_dir, product, registry_url, tag)
    print(f"  Wrote HOWTO:   {howto_path}")

    if args.push:
        print(f"\nPushing to OCI registry: {registry_url}/{tag}")
        ok = push_bundle(
            policy_path,
            catalog_copy_path,
            registry_url,
            tag,
            verbose=args.verbose,
        )
        if ok:
            print(f"\n  Bundle pushed. Next steps:")
            print(f"    cp {complytime_path} ~/.complytime/complytime.yaml")
            print(f"    complyctl get")
            print(f"    complyctl generate")
            print(f"    complyctl scan")
        else:
            sys.exit(1)
    else:
        print(f"\nBundle files written to {output_dir}")
        print(f"To push to a local registry:")
        print(f"  podman run -d -p 5000:5000 --name registry docker.io/library/registry:2")
        print(f"  python3 utils/nist_sync/generate_complyctl_bundle.py --product {product} --push")
        print(f"\nThen test with complyctl:")
        print(f"  cp {complytime_path} ~/.complytime/complytime.yaml")
        print(f"  complyctl get && complyctl generate && complyctl scan")


if __name__ == "__main__":
    main()
