#!/usr/bin/env python3
"""
Stage Gemara artifacts for a PR to complytime/complytime-policies.

Reads the Gemara export output (ControlCatalog, GuidanceCatalog) and generates
a directory tree matching the complytime-policies repository layout:

    output-dir/
    ├── bundles/
    │   └── nist-800-53-rev5-{product}.yaml        # bundle manifest
    ├── governance/
    │   ├── catalogs/
    │   │   └── nist-800-53-rev5-{product}-catalog.yaml
    │   ├── guidance/
    │   │   └── nist-800-53-rev5-guidance.yaml      # shared across products
    │   └── policies/
    │       └── nist-800-53-rev5-{product}-policy.yaml

Optionally opens a PR on a local clone of complytime-policies via `gh pr create`.

Usage:
    # Stage files only
    python3 utils/nist_sync/generate_policies_pr.py --products rhel9

    # Stage and copy into a local clone, then create PR
    python3 utils/nist_sync/generate_policies_pr.py \\
        --products rhel9 \\
        --policies-repo ~/complytime-policies \\
        --create-pr
"""

import argparse
import io
import shutil
import subprocess
import sys
from pathlib import Path

try:
    from ruamel.yaml import YAML
except ImportError:
    sys.stderr.write("Error: ruamel.yaml is required. Install with: pip install ruamel.yaml\n")
    sys.exit(1)

_SCRIPT_DIR = Path(__file__).parent
_REPO_ROOT = _SCRIPT_DIR.parent.parent

sys.path.insert(0, str(_SCRIPT_DIR))
from gemara.policy import extract_rules_from_catalog, generate_policy  # noqa: E402
from gemara.schema import validate_policy  # noqa: E402

_GUIDANCE_ID = "nist-800-53-rev5-guidance"


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


def policy_id_for(product):
    return f"nist-800-53-rev5-{product}"


def stage_product(product, gemara_dir, output_dir, has_guidance):
    """Stage one product's artifacts into complytime-policies layout."""
    catalog_path = gemara_dir / product / "control_catalog.yaml"
    if not catalog_path.exists():
        sys.stderr.write(
            f"ERROR: {catalog_path} not found.\n"
            f"Run first: python3 utils/nist_sync/export_to_gemara.py --products {product}\n"
        )
        return False

    pid = policy_id_for(product)
    catalog = load_yaml(catalog_path)
    catalog_id = catalog["metadata"]["id"]
    rules_with_controls = extract_rules_from_catalog(catalog, product=product)

    print(f"\n  [{product.upper()}] {len(rules_with_controls)} rules extracted from catalog")

    guidance_id = _GUIDANCE_ID if has_guidance else None
    catalog_url = f"file://../catalogs/{pid}-catalog.yaml"
    guidance_url = f"file://../guidance/{_GUIDANCE_ID}.yaml" if has_guidance else None

    policy = generate_policy(
        product, catalog_id, rules_with_controls,
        guidance_id=guidance_id,
        catalog_url=catalog_url,
        guidance_url=guidance_url,
    )

    errors = validate_policy(policy)
    if errors:
        sys.stderr.write("ERROR: Generated Policy failed validation:\n")
        for e in errors:
            sys.stderr.write(f"  - {e}\n")
        return False

    catalogs_dir = output_dir / "governance" / "catalogs"
    policies_dir = output_dir / "governance" / "policies"
    bundles_dir = output_dir / "bundles"

    catalogs_dir.mkdir(parents=True, exist_ok=True)
    policies_dir.mkdir(parents=True, exist_ok=True)
    bundles_dir.mkdir(parents=True, exist_ok=True)

    catalog_dest = catalogs_dir / f"{pid}-catalog.yaml"
    shutil.copy2(catalog_path, catalog_dest)
    print(f"  [{product.upper()}] Catalog:  {catalog_dest.relative_to(output_dir)}")

    policy_dest = policies_dir / f"{pid}-policy.yaml"
    dump_yaml(policy, policy_dest)
    print(f"  [{product.upper()}] Policy:   {policy_dest.relative_to(output_dir)}")

    layers = []
    if has_guidance:
        layers.append(f"governance/guidance/{_GUIDANCE_ID}.yaml")
    layers.append(f"governance/catalogs/{pid}-catalog.yaml")
    layers.append(f"governance/policies/{pid}-policy.yaml")

    bundle_manifest = {"layers": layers}
    bundle_dest = bundles_dir / f"{pid}.yaml"
    dump_yaml(bundle_manifest, bundle_dest)
    print(f"  [{product.upper()}] Bundle:   {bundle_dest.relative_to(output_dir)}")

    return True


def stage_guidance(gemara_dir, output_dir):
    """Copy the shared GuidanceCatalog if it exists."""
    guidance_path = gemara_dir / "guidance_catalog.yaml"
    if not guidance_path.exists():
        print("  [GUIDANCE] Not found — bundles will omit the guidance layer")
        return False

    guidance_dir = output_dir / "governance" / "guidance"
    guidance_dir.mkdir(parents=True, exist_ok=True)
    dest = guidance_dir / f"{_GUIDANCE_ID}.yaml"
    shutil.copy2(guidance_path, dest)
    print(f"  [GUIDANCE] {dest.relative_to(output_dir)}")
    return True


def copy_to_repo(output_dir, policies_repo):
    """Copy staged files into a local clone of complytime-policies."""
    for subdir in ("bundles", "governance"):
        src = output_dir / subdir
        if not src.exists():
            continue
        for src_file in src.rglob("*"):
            if src_file.is_dir():
                continue
            rel = src_file.relative_to(output_dir)
            dest_file = policies_repo / rel
            dest_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src_file, dest_file)
            print(f"  Copied: {rel}")


def create_pr(policies_repo, products, branch_name=None):
    """Create a PR on the complytime-policies repo via gh CLI."""
    gh = shutil.which("gh")
    if not gh:
        sys.stderr.write("ERROR: 'gh' CLI not found on PATH. Install from https://cli.github.com\n")
        return False

    if not branch_name:
        short_sha = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            cwd=str(_REPO_ROOT), capture_output=True, text=True,
        ).stdout.strip()
        branch_name = f"update/nist-800-53-from-content-{short_sha}"

    products_str = ", ".join(p.upper() for p in products)

    subprocess.run(
        ["git", "checkout", "-b", branch_name],
        cwd=str(policies_repo), check=True,
    )
    subprocess.run(
        ["git", "add", "-A"],
        cwd=str(policies_repo), check=True,
    )

    result = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        cwd=str(policies_repo),
    )
    if result.returncode == 0:
        print("\n  No changes to commit — complytime-policies is already up to date.")
        return True

    subprocess.run(
        ["git", "commit", "-m",
         f"chore: update NIST 800-53 artifacts for {products_str}\n\n"
         f"Generated from ComplianceAsCode/content gemara branch."],
        cwd=str(policies_repo), check=True,
    )
    subprocess.run(
        ["git", "push", "-u", "origin", branch_name],
        cwd=str(policies_repo), check=True,
    )

    pr_body = (
        "## Summary\n\n"
        f"Update NIST SP 800-53 Rev 5 Gemara artifacts for: {products_str}.\n\n"
        "Generated by `generate_policies_pr.py` from "
        "[ComplianceAsCode/content](https://github.com/ComplianceAsCode/content).\n\n"
        "### Artifacts updated\n\n"
        "- ControlCatalog (per product)\n"
        "- GuidanceCatalog (shared)\n"
        "- Policy (per product)\n"
        "- Bundle manifests (per product)\n\n"
        "### Verification\n\n"
        "- [ ] CUE schema validation passes\n"
        "- [ ] `gemara-publish-action` can assemble bundles\n"
    )

    subprocess.run(
        [gh, "pr", "create",
         "--title", f"Update NIST 800-53 artifacts for {products_str}",
         "--body", pr_body],
        cwd=str(policies_repo), check=True,
    )
    print("\n  PR created successfully.")
    return True


def parse_args():
    parser = argparse.ArgumentParser(
        description="Stage Gemara artifacts for a PR to complytime-policies",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--products",
        default="rhel9",
        help="Comma-separated product list (default: rhel9)",
    )
    parser.add_argument(
        "--gemara-dir",
        type=Path,
        default=_REPO_ROOT / "build" / "gemara",
        help="Directory containing gemara export output (default: build/gemara)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("/tmp/policies-staging"),
        help="Staging directory for the generated layout (default: /tmp/policies-staging)",
    )
    parser.add_argument(
        "--policies-repo",
        type=Path,
        default=None,
        help="Path to a local clone of complytime-policies (copies staged files there)",
    )
    parser.add_argument(
        "--create-pr",
        action="store_true",
        help="Create a PR on the policies repo via gh CLI (requires --policies-repo)",
    )
    parser.add_argument(
        "--branch",
        default=None,
        help="Branch name for the PR (default: update/nist-800-53-from-content-SHORTSHA)",
    )
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    products = [p.strip() for p in args.products.split(",") if p.strip()]
    gemara_dir = args.gemara_dir
    output_dir = args.output_dir

    if args.create_pr and not args.policies_repo:
        sys.stderr.write("ERROR: --create-pr requires --policies-repo\n")
        sys.exit(1)

    if output_dir.exists():
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True)

    print("Staging Gemara artifacts for complytime-policies PR")
    print(f"  Products: {', '.join(products)}")
    print(f"  Source:   {gemara_dir}")
    print(f"  Output:   {output_dir}")

    has_guidance = stage_guidance(gemara_dir, output_dir)

    all_ok = True
    for product in products:
        ok = stage_product(product, gemara_dir, output_dir, has_guidance)
        if not ok:
            all_ok = False

    if not all_ok:
        sys.stderr.write("\nERROR: Some products failed. Fix errors and retry.\n")
        sys.exit(1)

    print("\nStaged files:")
    for f in sorted(output_dir.rglob("*")):
        if f.is_file():
            print(f"  {f.relative_to(output_dir)}")

    if args.policies_repo:
        print(f"\nCopying to {args.policies_repo} ...")
        copy_to_repo(output_dir, args.policies_repo)

        if args.create_pr:
            print("\nCreating PR ...")
            create_pr(args.policies_repo, products, branch_name=args.branch)

    print("\nDone.")


if __name__ == "__main__":
    main()
