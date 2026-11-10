#!/usr/bin/env python3
"""
Tests for the profile-driven Gemara export (export_profiles_to_gemara.py).

Reads the resolved profiles the build emits (build/<product>/profiles/*.profile)
and verifies that a Policy built from a resolved profile:
  1. honors the profile's customizations (unselected rule absent, variable
     overrides captured as parameters);
  2. matches the resolved selection count exactly;
  3. passes the structural validator;
plus a smoke test of the shared all-rules catalog.

Build first:  ./build_product rhel9   (or --datastream)

Usage:
    python3 utils/nist_sync/test_gemara_profiles.py
    python3 utils/nist_sync/test_gemara_profiles.py --product rhel9 --profile stig
"""

import argparse
import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).parent
_REPO_ROOT = _SCRIPT_DIR.parent.parent
sys.path.insert(0, str(_SCRIPT_DIR))

from gemara.frameworks import framework_for_control_file  # noqa: E402
from gemara.policy import product_full_name  # noqa: E402
from gemara.profiles import (  # noqa: E402
    AllRulesCatalogBuilder,
    generate_profile_policy,
    pair_vars_to_rules,
    read_resolved_profile,
)
from gemara.schema import validate_catalog, validate_policy  # noqa: E402


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

    # --- policy build -----------------------------------------------------
    print("\n[2] Policy build")
    stem = resolved.policies[0] if resolved.policies else "generic"
    framework = framework_for_control_file(stem, args.product)
    catalog_id = framework.catalog_id(args.product)
    rules_with_params = pair_vars_to_rules(resolved.rules, resolved.variables)
    policy = generate_profile_policy(
        args.product, product_full_name(args.product), resolved, catalog_id,
        catalog_url=None, framework=framework, rules_with_params=rules_with_params,
    )
    r.check(not validate_policy(policy), "policy passes validate_policy()")
    r.check(policy["metadata"]["id"] == f"{args.product}-{resolved.name}-policy",
            f"policy id is {args.product}-{resolved.name}-policy")
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

    # --- all-rules catalog smoke -----------------------------------------
    print("\n[3] Shared all-rules catalog")
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
