#!/usr/bin/env python3
"""
Tests for the Gemara export output.

Verifies that the generated Gemara YAML files:
  1. Can be parsed as valid YAML
  2. Have correct structural cross-references (group IDs, applicability IDs)
  3. Are accurate: rules in the output match rules in the source control files
  4. Have expected counts (no controls dropped, no rules silently omitted)

Usage:
    python3 utils/nist_sync/test_gemara_export.py
    python3 utils/nist_sync/test_gemara_export.py --products rhel9
    python3 utils/nist_sync/test_gemara_export.py --gemara-dir /tmp/gemara
"""

import argparse
import sys
from pathlib import Path

try:
    from ruamel.yaml import YAML
except ImportError:
    sys.stderr.write("Error: ruamel.yaml is required.\n")
    sys.exit(1)

try:
    import ssg.controls
except (ModuleNotFoundError, ImportError):
    sys.stderr.write("Unable to load ssg python modules.\n")
    sys.stderr.write("Hint: run source ./.pyenv.sh\n")
    sys.exit(3)

_SCRIPT_DIR = Path(__file__).parent
_REPO_ROOT = _SCRIPT_DIR.parent.parent
_YAML = YAML()

sys.path.insert(0, str(_SCRIPT_DIR))
from gemara.policy import extract_rules_from_catalog, generate_policy  # noqa: E402
from gemara.schema import validate_policy  # noqa: E402


def load_yaml(path):
    with open(path) as f:
        return _YAML.load(f)


def load_policy(product, repo_root):
    policy_file = repo_root / "products" / product / "controls" / "nist_800_53.yml"
    policy = ssg.controls.Policy(str(policy_file), env_yaml=None)
    policy.load()
    return policy


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

class TestResult:
    def __init__(self):
        self.passed = []
        self.failed = []

    def ok(self, msg):
        self.passed.append(msg)
        print(f"  [PASS] {msg}")

    def fail(self, msg):
        self.failed.append(msg)
        print(f"  [FAIL] {msg}")

    def check(self, condition, ok_msg, fail_msg):
        if condition:
            self.ok(ok_msg)
        else:
            self.fail(fail_msg)


# ---------------------------------------------------------------------------
# Test suites
# ---------------------------------------------------------------------------

def test_catalog_structure(catalog, result):
    """Verify internal cross-reference integrity of the ControlCatalog."""
    meta = catalog.get("metadata", {})
    result.check(
        meta.get("type") == "ControlCatalog",
        "metadata.type is 'ControlCatalog'",
        f"metadata.type is wrong: {meta.get('type')}",
    )
    result.check(
        "gemara-version" in meta,
        "metadata.gemara-version present",
        "metadata.gemara-version missing",
    )

    defined_group_ids = {g["id"] for g in catalog.get("groups", [])}
    app_group_ids = {g["id"] for g in meta.get("applicability-groups", [])}

    result.check(len(defined_group_ids) >= 20, f"{len(defined_group_ids)} NIST families defined as groups", "fewer than 20 NIST families defined")
    result.check(len(app_group_ids) >= 3, f"{len(app_group_ids)} applicability groups (baselines) defined", "fewer than 3 baselines defined")

    controls = catalog.get("controls", [])
    result.check(len(controls) > 0, f"{len(controls)} controls present in catalog", "no controls in catalog")

    bad_groups = []
    bad_app_refs = []
    missing_objective = []
    bad_states = []
    valid_states = {"Active", "Draft", "Deprecated", "Retired"}
    seen_ids = set()
    dup_ids = []

    for ctrl in controls:
        cid = ctrl.get("id", "<no-id>")
        if cid in seen_ids:
            dup_ids.append(cid)
        seen_ids.add(cid)

        if ctrl.get("group") not in defined_group_ids:
            bad_groups.append(cid)
        if ctrl.get("state") not in valid_states:
            bad_states.append(cid)
        if not ctrl.get("objective"):
            missing_objective.append(cid)
        for req in ctrl.get("assessment-requirements", []):
            for ref in req.get("applicability", []):
                if ref not in app_group_ids:
                    bad_app_refs.append(f"{cid}:{ref}")

    result.check(not dup_ids, "no duplicate control IDs", f"duplicate IDs: {dup_ids[:5]}")
    result.check(not bad_groups, "all control group references resolve", f"unresolved groups: {bad_groups[:5]}")
    result.check(not bad_states, "all control states are valid", f"invalid states: {bad_states[:5]}")
    result.check(not missing_objective, "all controls have an objective", f"missing objective: {missing_objective[:5]}")
    result.check(not bad_app_refs, "all applicability references resolve", f"unresolved: {bad_app_refs[:5]}")


def test_mapping_structure(mapping, result):
    """Verify internal cross-reference integrity of the MappingDocument."""
    meta = mapping.get("metadata", {})
    result.check(
        meta.get("type") == "MappingDocument",
        "metadata.type is 'MappingDocument'",
        f"metadata.type wrong: {meta.get('type')}",
    )

    mappings = mapping.get("mappings", [])
    result.check(len(mappings) > 0, f"{len(mappings)} mapping entries", "no mapping entries")

    valid_rels = {"implements", "implemented-by", "supports", "supported-by", "equivalent", "subsumes", "no-match", "relates-to"}
    bad_rels = []
    missing_targets = []
    seen_ids = set()
    dup_ids = []

    for m in mappings:
        mid = m.get("id", "<no-id>")
        if mid in seen_ids:
            dup_ids.append(mid)
        seen_ids.add(mid)
        rel = m.get("relationship")
        if rel not in valid_rels:
            bad_rels.append(f"{mid}:{rel}")
        if rel != "no-match" and not m.get("targets"):
            missing_targets.append(mid)
        for t in m.get("targets", []):
            s = t.get("strength", 0)
            if not (1 <= s <= 10):
                bad_rels.append(f"{mid}: strength {s} out of range")

    result.check(not dup_ids, "no duplicate mapping IDs", f"duplicate IDs: {dup_ids[:5]}")
    result.check(not bad_rels, "all relationships and strengths are valid", f"invalid: {bad_rels[:5]}")
    result.check(not missing_targets, "all non-no-match mappings have targets", f"missing targets: {missing_targets[:5]}")


def test_accuracy_vs_source(catalog, mapping, policy, product, result):
    """Cross-check generated output against the source CaC control files."""
    # Control count must match exactly
    src_count = len(policy.controls)
    out_count = len(catalog.get("controls", []))
    result.check(
        src_count == out_count,
        f"control count matches source: {out_count}",
        f"control count mismatch: source={src_count} output={out_count}",
    )

    catalog_by_id = {c["id"]: c for c in catalog.get("controls", [])}
    mapping_by_source = {}
    for m in mapping.get("mappings", []):
        mapping_by_source.setdefault(m["source"], []).append(m)

    # Spot-check all controls that have rules in source
    rule_mismatch = []
    missing_controls = []

    for src_ctrl in policy.controls:
        cid = src_ctrl.id
        if cid not in catalog_by_id:
            missing_controls.append(cid)
            continue

        out_ctrl = catalog_by_id[cid]

        # Collect expected pure rule IDs from source (excluding variable assignments)
        src_rules = {r for r in (src_ctrl.rules or []) if "=" not in r}

        # Collect rule IDs from assessment-requirements in catalog output.
        # Exclude variable-assignment requirements (text starts with "Variable '")
        # and placeholder requirements (id is "no-automated-check")
        out_req_rules = set()
        for req in out_ctrl.get("assessment-requirements", []):
            req_text = req.get("text", "")
            if req_text.startswith("Variable '"):
                continue
            req_id = req["id"]
            if req_id == "no-automated-check":
                continue
            out_req_rules.add(req_id)

        missing_from_output = src_rules - out_req_rules
        extra_in_output = out_req_rules - src_rules
        if missing_from_output or extra_in_output:
            rule_mismatch.append(
                f"{cid}: missing={sorted(missing_from_output)[:3]} extra={sorted(extra_in_output)[:3]}"
            )

    result.check(not missing_controls, "all source controls present in output", f"missing: {missing_controls[:5]}")
    result.check(not rule_mismatch, "all source rules present in output assessment-requirements", f"mismatches (first 3): {rule_mismatch[:3]}")

    # Spot-check ac-2.5 if it exists (known automated control with specific rules)
    ac25_src = next((c for c in policy.controls if c.id == "ac-2.5"), None)
    if ac25_src and ac25_src.rules:
        ac25_out = catalog_by_id.get("ac-2.5")
        if ac25_out:
            req_rule_ids = {
                req["id"]
                for req in ac25_out.get("assessment-requirements", [])
                if not req.get("text", "").startswith("Variable '")
                and req["id"] != "no-automated-check"
            }
            expected = {"accounts_tmout", "no_invalid_shell_accounts_unlocked"}
            found = expected & req_rule_ids
            result.check(
                found == expected,
                f"ac-2.5 has expected rules: {sorted(found)}",
                f"ac-2.5 missing rules: {expected - found}",
            )
            result.check(
                ac25_out.get("state") == "Active",
                "ac-2.5 state is 'Active' (automated control)",
                f"ac-2.5 state is {ac25_out.get('state')!r}",
            )
            ac25_maps = mapping_by_source.get("ac-2.5", [])
            mapped_rule_ids = {t["entry-id"] for m in ac25_maps for t in m.get("targets", [])}
            result.check(
                "accounts_tmout" in mapped_rule_ids,
                "ac-2.5 → accounts_tmout appears in MappingDocument",
                "ac-2.5 → accounts_tmout missing from MappingDocument",
            )

    # Pending controls should not appear in mapping (they have no rules)
    pending_in_mapping = [
        m["source"] for m in mapping.get("mappings", [])
        if any(c.id == m["source"] and (c.status or "pending") in {"pending", "planned", "does not meet", "not applicable"}
               for c in policy.controls)
    ]
    result.check(
        not pending_in_mapping,
        "pending/planned/does-not-meet controls absent from MappingDocument",
        f"pending controls leaked into mapping: {pending_in_mapping[:5]}",
    )


def test_guidance_structure(guidance, result):
    """Verify internal cross-reference integrity of the GuidanceCatalog."""
    meta = guidance.get("metadata", {})
    result.check(
        meta.get("type") == "GuidanceCatalog",
        "metadata.type is 'GuidanceCatalog'",
        f"metadata.type is wrong: {meta.get('type')}",
    )
    result.check(
        "gemara-version" in meta,
        "metadata.gemara-version present",
        "metadata.gemara-version missing",
    )
    result.check(
        guidance.get("type") == "Standard",
        "type is 'Standard'",
        f"type is wrong: {guidance.get('type')}",
    )

    defined_group_ids = {g["id"] for g in guidance.get("groups", [])}
    app_group_ids = {g["id"] for g in meta.get("applicability-groups", [])}

    result.check(len(defined_group_ids) >= 20, f"{len(defined_group_ids)} NIST families defined as groups", "fewer than 20 NIST families defined")
    result.check("low" in app_group_ids and "moderate" in app_group_ids and "high" in app_group_ids,
                 "low/moderate/high applicability-groups present",
                 f"missing baseline applicability-groups: {app_group_ids}")

    guidelines = guidance.get("guidelines", [])
    result.check(len(guidelines) >= 1000, f"{len(guidelines)} guidelines present", f"fewer than 1000 guidelines: {len(guidelines)}")

    bad_groups = []
    bad_app_refs = []
    missing_objective = []
    bad_states = []
    valid_states = {"Active", "Draft", "Deprecated", "Retired"}
    seen_ids = set()
    dup_ids = []

    for gl in guidelines:
        gid = gl.get("id", "<no-id>")
        if gid in seen_ids:
            dup_ids.append(gid)
        seen_ids.add(gid)
        if gl.get("group") not in defined_group_ids:
            bad_groups.append(gid)
        if gl.get("state") not in valid_states:
            bad_states.append(gid)
        if not gl.get("objective"):
            missing_objective.append(gid)
        for ref in gl.get("applicability", []):
            if ref not in app_group_ids:
                bad_app_refs.append(f"{gid}:{ref}")

    result.check(not dup_ids, "no duplicate guideline IDs", f"duplicate IDs: {dup_ids[:5]}")
    result.check(not bad_groups, "all guideline group references resolve", f"unresolved groups: {bad_groups[:5]}")
    result.check(not bad_states, "all guideline states are valid", f"invalid states: {bad_states[:5]}")
    result.check(not missing_objective, "all guidelines have an objective", f"missing objective: {missing_objective[:5]}")
    result.check(not bad_app_refs, "all applicability references resolve", f"unresolved: {bad_app_refs[:5]}")

    # Spot-check ac-2.5: moderate+high only, not low
    ac25 = next((g for g in guidelines if g.get("id") == "ac-2.5"), None)
    if ac25:
        appl = set(ac25.get("applicability", []))
        result.check(
            "moderate" in appl and "high" in appl and "low" not in appl,
            "ac-2.5 applicability is [moderate, high] (not low)",
            f"ac-2.5 applicability wrong: {sorted(appl)}",
        )
        result.check(
            ac25.get("title") == "Inactivity Logout",
            "ac-2.5 title is 'Inactivity Logout'",
            f"ac-2.5 title wrong: {ac25.get('title')!r}",
        )
        result.check(
            "log out" in (ac25.get("objective") or "").lower(),
            "ac-2.5 objective mentions 'log out'",
            f"ac-2.5 objective unexpected: {ac25.get('objective')!r}",
        )
    else:
        result.fail("ac-2.5 not found in guidelines")


def test_policy_generation(catalog, product, result):
    """Test Policy generation from a ControlCatalog."""
    catalog_id = catalog["metadata"]["id"]
    rules = extract_rules_from_catalog(catalog, product=product)

    result.check(len(rules) > 0, f"extracted {len(rules)} rules from catalog", "no rules extracted from catalog")

    policy = generate_policy(product, catalog_id, rules)

    errors = validate_policy(policy)
    result.check(not errors, "generated Policy passes validate_policy()", f"validation errors: {errors[:3]}")

    meta = policy.get("metadata", {})
    result.check(
        meta.get("type") == "Policy",
        "metadata.type is 'Policy'",
        f"metadata.type is {meta.get('type')!r}",
    )
    result.check(
        meta.get("id") == f"nist-800-53-rev5-{product}-policy",
        f"metadata.id is 'nist-800-53-rev5-{product}-policy'",
        f"metadata.id is {meta.get('id')!r}",
    )

    plans = policy.get("adherence", {}).get("assessment-plans", [])
    result.check(
        len(plans) == len(rules),
        f"assessment-plans count matches extracted rules: {len(plans)}",
        f"count mismatch: plans={len(plans)} rules={len(rules)}",
    )

    plan_ids = {p["id"] for p in plans}
    rule_ids = {r[0] for r in rules}
    result.check(
        plan_ids == rule_ids,
        "assessment-plan IDs match extracted rule IDs",
        f"mismatch: only_in_plans={plan_ids - rule_ids} only_in_rules={rule_ids - plan_ids}",
    )

    imports = policy.get("imports", {})
    cat_refs = [c["reference-id"] for c in imports.get("catalogs", [])]
    result.check(
        catalog_id in cat_refs,
        f"imports.catalogs references catalog '{catalog_id}'",
        f"catalog not in imports: {cat_refs}",
    )


def test_policy_with_guidance(catalog, product, result):
    """Test Policy generation with guidance references (complytime-policies mode)."""
    catalog_id = catalog["metadata"]["id"]
    rules = extract_rules_from_catalog(catalog, product=product)
    guidance_id = "nist-800-53-rev5-guidance"

    policy = generate_policy(
        product, catalog_id, rules,
        guidance_id=guidance_id,
        catalog_url=f"file://../catalogs/nist-800-53-rev5-{product}-catalog.yaml",
        guidance_url=f"file://../guidance/{guidance_id}.yaml",
    )

    errors = validate_policy(policy)
    result.check(not errors, "Policy with guidance passes validation", f"errors: {errors[:3]}")

    mapping_refs = policy["metadata"]["mapping-references"]
    ref_ids = {r["id"] for r in mapping_refs}
    result.check(
        guidance_id in ref_ids,
        "guidance ID in mapping-references",
        f"guidance missing from mapping-references: {ref_ids}",
    )

    catalog_ref = next(r for r in mapping_refs if r["id"] == catalog_id)
    result.check(
        "file://" in catalog_ref.get("url", ""),
        "catalog mapping-reference has file:// URL",
        f"catalog URL: {catalog_ref.get('url')!r}",
    )

    guidance_imports = policy.get("imports", {}).get("guidance", [])
    result.check(
        any(g.get("reference-id") == guidance_id for g in guidance_imports),
        "imports.guidance references guidance catalog",
        f"guidance not in imports: {guidance_imports}",
    )


def test_baseline_filtering(catalog, product, result):
    """Test that baseline filtering reduces the rule set."""
    all_rules = extract_rules_from_catalog(catalog, product=product)
    low_rules = extract_rules_from_catalog(catalog, baseline="low", product=product)
    moderate_rules = extract_rules_from_catalog(catalog, baseline="moderate", product=product)
    high_rules = extract_rules_from_catalog(catalog, baseline="high", product=product)

    result.check(
        len(all_rules) > 0,
        f"all rules (no filter): {len(all_rules)}",
        "no rules without filter",
    )
    result.check(
        len(low_rules) >= len(moderate_rules),
        f"low ({len(low_rules)}) >= moderate ({len(moderate_rules)})",
        f"low ({len(low_rules)}) < moderate ({len(moderate_rules)})",
    )
    result.check(
        len(moderate_rules) >= len(high_rules),
        f"moderate ({len(moderate_rules)}) >= high ({len(high_rules)})",
        f"moderate ({len(moderate_rules)}) < high ({len(high_rules)})",
    )


def test_validate_policy_catches_errors(result):
    """Test that validate_policy() catches structural problems."""
    errors = validate_policy({})
    result.check(
        len(errors) > 0,
        f"empty dict produces {len(errors)} errors",
        "empty dict produced no errors",
    )

    errors = validate_policy("not a dict")
    result.check(
        "policy must be a dict" in errors,
        "non-dict input detected",
        f"unexpected errors: {errors}",
    )

    minimal = {
        "title": "T",
        "metadata": {"id": "x", "type": "Policy", "gemara-version": "1.2.0",
                      "description": "d", "author": {"id": "a", "name": "n", "type": "Software"},
                      "mapping-references": [{"id": "c", "title": "t", "version": "v"}]},
        "contacts": {"responsible": [], "accountable": []},
        "scope": {"in": {"technologies": []}},
        "imports": {"catalogs": [{"reference-id": "c"}]},
        "adherence": {"assessment-plans": [{"id": "r1", "requirement-id": "r1"}]},
    }
    errors = validate_policy(minimal)
    result.check(
        len(errors) == 0,
        "minimal valid Policy passes validation",
        f"minimal Policy has errors: {errors}",
    )

    bad_ref = dict(minimal)
    bad_ref["imports"] = {"catalogs": [{"reference-id": "nonexistent"}]}
    errors = validate_policy(bad_ref)
    result.check(
        any("not in mapping-references" in e for e in errors),
        "mismatched catalog reference detected",
        f"reference mismatch not caught: {errors}",
    )


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def run_guidance(gemara_dir, result):
    guidance_path = gemara_dir / "guidance_catalog.yaml"
    if not guidance_path.exists():
        print("  [SKIP] guidance_catalog.yaml not found — OSCAL data not downloaded")
        print("         Run: python3 utils/nist_sync/download_oscal.py && python3 utils/nist_sync/export_to_gemara.py")
        return
    guidance = load_yaml(guidance_path)
    result.ok(f"guidance_catalog.yaml parsed ({guidance_path})")
    test_guidance_structure(guidance, result)


def run_product(product, gemara_dir, repo_root):
    print(f"\n{'='*60}")
    print(f"Product: {product}")
    print(f"{'='*60}")
    result = TestResult()

    catalog_path = gemara_dir / product / "control_catalog.yaml"
    mapping_path = gemara_dir / product / "rules_mapping.yaml"

    if not catalog_path.exists():
        print(f"  [SKIP] {catalog_path} not found — run export_to_gemara.py first")
        return result

    print("\n[1] Loading output files...")
    catalog = load_yaml(catalog_path)
    result.ok(f"control_catalog.yaml parsed ({catalog_path})")
    mapping = None
    if mapping_path.exists():
        mapping = load_yaml(mapping_path)
        result.ok(f"rules_mapping.yaml parsed ({mapping_path})")
    else:
        result.fail(f"rules_mapping.yaml not found at {mapping_path}")

    print("\n[2] ControlCatalog structure...")
    test_catalog_structure(catalog, result)

    if mapping:
        print("\n[3] MappingDocument structure...")
        test_mapping_structure(mapping, result)

    print("\n[4] Accuracy vs source control files...")
    policy = load_policy(product, repo_root)
    test_accuracy_vs_source(catalog, mapping or {}, policy, product, result)

    print("\n[5] Policy generation...")
    test_policy_generation(catalog, product, result)

    print("\n[6] Policy with guidance (complytime-policies mode)...")
    test_policy_with_guidance(catalog, product, result)

    print("\n[7] Baseline filtering...")
    test_baseline_filtering(catalog, product, result)

    return result


def main():
    parser = argparse.ArgumentParser(description="Test Gemara export output")
    parser.add_argument(
        "--products",
        default="rhel8,rhel9,rhel10",
        help="Comma-separated product list",
    )
    parser.add_argument(
        "--gemara-dir",
        type=Path,
        default=_REPO_ROOT / "build" / "gemara",
        help="Directory containing gemara export output",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=_REPO_ROOT,
    )
    args = parser.parse_args()
    products = [p.strip() for p in args.products.split(",") if p.strip()]

    all_passed = 0
    all_failed = 0

    print(f"\n{'='*60}")
    print("GuidanceCatalog (platform-independent)")
    print(f"{'='*60}")
    guidance_result = TestResult()
    run_guidance(args.gemara_dir, guidance_result)
    all_passed += len(guidance_result.passed)
    all_failed += len(guidance_result.failed)

    print(f"\n{'='*60}")
    print("Policy validation (product-independent)")
    print(f"{'='*60}")
    validation_result = TestResult()
    test_validate_policy_catches_errors(validation_result)
    all_passed += len(validation_result.passed)
    all_failed += len(validation_result.failed)

    for product in products:
        result = run_product(product, args.gemara_dir, args.repo_root)
        all_passed += len(result.passed)
        all_failed += len(result.failed)

    print(f"\n{'='*60}")
    print(f"SUMMARY: {all_passed} passed, {all_failed} failed")
    print(f"{'='*60}")
    sys.exit(0 if all_failed == 0 else 1)


if __name__ == "__main__":
    main()
