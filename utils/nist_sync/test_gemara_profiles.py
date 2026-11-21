#!/usr/bin/env python3
"""
Tests for the profile-driven Gemara export (export_to_gemara.py --mode profiles).

Reads the resolved profiles the build emits (build/<product>/profiles/*.profile)
and verifies that a Policy built from a resolved profile:
  1. honors the profile's customizations (unselected rule absent, variable
     overrides captured as parameters);
  2. matches the resolved selection count exactly;
  3. passes the structural validator;
  4. advertises the same benchmark version as the catalog it imports, and the
     catalog id carries no version suffix (versionless naming, version lives in
     metadata.version);
plus a smoke test of the shared all-rules catalog.

Build first:  ./build_product rhel9   (or --datastream)

Usage:
    python3 utils/nist_sync/test_gemara_profiles.py
    python3 utils/nist_sync/test_gemara_profiles.py --product rhel9 --profile stig
"""

import argparse
import sys
from pathlib import Path

import ssg.controls
import ssg.yaml  # noqa: E402

_SCRIPT_DIR = Path(__file__).parent
_REPO_ROOT = _SCRIPT_DIR.parent.parent
sys.path.insert(0, str(_SCRIPT_DIR))

from gemara.catalog import GemaraCatalogBuilder  # noqa: E402
from gemara.frameworks import (  # noqa: E402
    Framework,
    framework_for_control_file,
    product_display,
)
from gemara.policy import product_full_name  # noqa: E402
from gemara.profiles import (  # noqa: E402
    AllRulesCatalogBuilder,
    generate_profile_policy,
    pair_vars_to_rules,
    read_resolved_profile,
    sanitize_id,
)
from gemara.schema import validate_catalog, validate_policy  # noqa: E402


def _resolve_control_file(product: str, stem: str):
    for cand in (
        _REPO_ROOT / "products" / product / "controls" / f"{stem}.yml",
        _REPO_ROOT / "controls" / f"{stem}.yml",
    ):
        if cand.exists():
            return cand
    return None


class Result:
    def __init__(self):
        self.failed = 0

    def check(self, cond, msg):
        print(f"  [{'PASS' if cond else 'FAIL'}] {msg}")
        if not cond:
            self.failed += 1


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--product", default="rhel9")
    ap.add_argument("--profile", default="stig")
    # The rule the STIG profile is known to unselect, and a variable it overrides.
    ap.add_argument("--unselected-rule", default="audit_rules_immutable_login_uids")
    ap.add_argument("--expect-var", default="var_password_pam_minlen")
    args = ap.parse_args()

    prof = _REPO_ROOT / "build" / args.product / "profiles" / f"{args.profile}.profile"
    if not prof.exists():
        sys.stderr.write(
            f"ERROR: {prof} not found. Build first: ./build_product {args.product}\n"
        )
        sys.exit(3)

    r = Result()
    resolved = read_resolved_profile(prof)
    print(f"Profile: {resolved.name}  rules={len(resolved.rules)} "
          f"vars={len(resolved.variables)}  policies={resolved.policies}")

    # --- customization fidelity ------------------------------------------
    print("\n[1] Customization fidelity")
    r.check(args.unselected_rule not in resolved.rules,
            f"unselected rule {args.unselected_rule!r} absent from resolved selection")
    var_names = {k for k, _ in resolved.variables}
    r.check(args.expect_var in var_names,
            f"variable {args.expect_var!r} present in resolved selection")

    # --- catalog + version ------------------------------------------------
    print("\n[2] Catalog + version")
    stem = resolved.policies[0] if resolved.policies else None
    if stem:
        framework = framework_for_control_file(stem, args.product)
        catalog_id = framework.catalog_id(args.product)
    else:
        # Mirror the exporter: profiles with no backing control file use the
        # shared per-product all-rules catalog.
        framework = Framework(
            key=sanitize_id(args.product) + "-rules", reference_type="rule",
            short_name=f"{product_display(args.product)} Rules",
            long_name=f"{product_display(args.product)} Rules",
        )
        catalog_id = f"{sanitize_id(args.product)}-rules"
    catalog_version = ""
    control_file = _resolve_control_file(args.product, stem) if stem else None
    if control_file:
        raw = ssg.yaml.open_raw(str(control_file))
        ctrl_version = str(raw.get("version") or "") if isinstance(raw, dict) else ""
        policy_obj = ssg.controls.Policy(str(control_file), env_yaml=None)
        policy_obj.load()
        catalog = GemaraCatalogBuilder(
            args.product, policy_obj, framework=framework,
            version=ctrl_version or None,
        ).build()
        catalog_version = catalog["metadata"].get("version") or ""
        r.check(not validate_catalog(catalog), "catalog passes validate_catalog()")
        if ctrl_version:
            r.check(catalog_version == ctrl_version,
                    f"catalog metadata.version is the control-file version "
                    f"{ctrl_version!r}")
    else:
        print("  (no backing control file; using versionless generic catalog)")

    # Versionless naming: the version must live in metadata.version, not the id.
    r.check(not catalog_version or catalog_version not in catalog_id,
            f"catalog id {catalog_id!r} carries no version suffix")

    # --- policy build -----------------------------------------------------
    print("\n[3] Policy build")
    rules_with_params = pair_vars_to_rules(resolved.rules, resolved.variables)
    policy = generate_profile_policy(
        args.product, product_full_name(args.product), resolved, catalog_id,
        catalog_url=None, framework=framework, rules_with_params=rules_with_params,
        version=catalog_version,
    )
    r.check(not validate_policy(policy), "policy passes validate_policy()")
    expected_policy_id = f"{sanitize_id(args.product)}-{sanitize_id(resolved.name)}-policy"
    r.check(policy["metadata"]["id"] == expected_policy_id,
            f"policy id is {expected_policy_id}")
    plans = policy["adherence"]["assessment-plans"]
    r.check(len(plans) == len(resolved.rules),
            f"assessment-plan count matches resolved rules: {len(plans)}")
    plan_ids = {p["id"] for p in plans}
    r.check(args.unselected_rule not in plan_ids,
            "unselected rule absent from assessment-plans")

    # the override must land as a parameter on at least one plan
    param_vars = {
        p["id"] for plan in plans for p in plan.get("parameters", [])
    }
    r.check(args.expect_var in param_vars,
            f"variable {args.expect_var!r} captured as a plan parameter")

    # --- version consistency ---------------------------------------------
    print("\n[4] Policy/catalog version consistency")
    ref_version = policy["metadata"]["mapping-references"][0].get("version")
    r.check(ref_version == catalog_version,
            f"policy mapping-reference version {ref_version!r} matches catalog "
            f"{catalog_version!r}")

    # --- all-rules catalog smoke -----------------------------------------
    print("\n[5] Shared all-rules catalog")
    cat = AllRulesCatalogBuilder(args.product, resolved.rules[:50]).build()
    r.check(not validate_catalog(cat), "all-rules catalog passes validate_catalog()")
    r.check(cat["metadata"]["id"] == f"{args.product}-rules",
            f"all-rules catalog id is {args.product}-rules")

    print("\n" + "=" * 56)
    print(f"SUMMARY: {'FAILED' if r.failed else 'OK'} ({r.failed} failed)")
    print("=" * 56)
    sys.exit(1 if r.failed else 0)


if __name__ == "__main__":
    main()
