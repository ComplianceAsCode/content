#!/usr/bin/env python3
"""
Tests for the framework abstraction (non-NIST Gemara export).

Builds Gemara artifacts for a generic framework (default: DISA STIG on rhel9)
straight from the ComplianceAsCode control file — no prior export run needed —
and verifies:

  1. Catalog / policy / guidance / mapping pass the structural validators.
  2. The framework's identity is reflected in ids, grouping, and version.
  3. Rules round-trip: every source rule appears as an assessment-requirement
     and as an assessment-plan.
  4. The NIST framework still produces NIST ids (guards the shared code path).

Usage:
    python3 utils/nist_sync/test_gemara_frameworks.py
    python3 utils/nist_sync/test_gemara_frameworks.py --framework stig --product rhel9
"""

import argparse
import sys
from pathlib import Path

try:
    import ssg.controls
    import ssg.yaml
except (ModuleNotFoundError, ImportError):
    sys.stderr.write("Unable to load ssg python modules.\nHint: run source ./.pyenv.sh\n")
    sys.exit(3)

_SCRIPT_DIR = Path(__file__).parent
_REPO_ROOT = _SCRIPT_DIR.parent.parent

sys.path.insert(0, str(_SCRIPT_DIR))
from gemara.catalog import GemaraCatalogBuilder  # noqa: E402
from gemara.frameworks import get_framework  # noqa: E402
from gemara.guidance import GenericGuidanceCatalogBuilder  # noqa: E402
from gemara.mapping import GemaraMappingBuilder  # noqa: E402
from gemara.policy import extract_rules_from_catalog, generate_policy  # noqa: E402
from gemara.schema import (  # noqa: E402
    validate_catalog,
    validate_guidance,
    validate_mapping,
    validate_policy,
)


class Result:
    def __init__(self) -> None:
        self.failed = 0

    def check(self, cond: bool, msg: str) -> None:
        if cond:
            print(f"  [PASS] {msg}")
        else:
            self.failed += 1
            print(f"  [FAIL] {msg}")


def resolve_control_file(product: str, stems) -> Path:
    for stem in stems:
        for cand in (
            _REPO_ROOT / "products" / product / "controls" / f"{stem}.yml",
            _REPO_ROOT / "controls" / f"{stem}.yml",
        ):
            if cand.exists():
                return cand
    raise FileNotFoundError(f"no control file for {product} among {stems}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--framework", default="stig")
    parser.add_argument("--product", default="rhel9")
    parser.add_argument("--control", default=None)
    args = parser.parse_args()

    fw = get_framework(args.framework)
    product = args.product
    stems = [args.control] if args.control else [f"{fw.key}_{product}", fw.key]
    control_file = resolve_control_file(product, stems)
    print(f"Framework: {args.framework}  product: {product}")
    print(f"Control file: {control_file}")

    policy_obj = ssg.controls.Policy(str(control_file), env_yaml=None)
    policy_obj.load()
    raw = ssg.yaml.open_raw(str(control_file))
    version = str(raw.get("version")) if isinstance(raw, dict) and raw.get("version") else None

    r = Result()

    # --- ControlCatalog ---------------------------------------------------
    print("\n[1] ControlCatalog")
    builder = GemaraCatalogBuilder(product, policy_obj, framework=fw, version=version)
    catalog = builder.build()
    r.check(not validate_catalog(catalog), "catalog passes validate_catalog()")
    r.check(catalog["metadata"]["id"] == fw.catalog_id(product),
            f"catalog id is {fw.catalog_id(product)!r}")
    r.check(catalog["metadata"]["type"] == "ControlCatalog", "type is ControlCatalog")
    if version:
        r.check(catalog["metadata"]["version"] == version,
                f"catalog version is {version!r}")
    group_ids = {g["id"] for g in catalog["groups"]}
    ctrl_groups = {c["group"] for c in catalog["controls"]}
    r.check(ctrl_groups <= group_ids, "every control group resolves to a defined group")
    r.check(len(catalog["controls"]) == len(policy_obj.controls),
            f"control count matches source: {len(catalog['controls'])}")

    # --- GuidanceCatalog (synthetic) --------------------------------------
    print("\n[2] GuidanceCatalog (synthetic)")
    guidance = GenericGuidanceCatalogBuilder(
        policy_obj, fw, guidance_id=f"{fw.key}-{product}-guidance", version=version
    ).build()
    r.check(not validate_guidance(guidance), "guidance passes validate_guidance()")
    r.check(len(guidance["guidelines"]) >= 1, "guidance has guidelines")

    # --- MappingDocument --------------------------------------------------
    print("\n[3] MappingDocument")
    mapping = GemaraMappingBuilder(
        product, catalog["metadata"]["id"], policy_obj, framework=fw, version=version
    ).build()
    r.check(not validate_mapping(mapping), "mapping passes validate_mapping()")

    # --- Policy -----------------------------------------------------------
    print("\n[4] Policy")
    rules = extract_rules_from_catalog(catalog, product=product)
    policy = generate_policy(
        product, catalog["metadata"]["id"], rules,
        guidance_id=f"{fw.key}-{product}-guidance",
        catalog_url=f"file://../catalogs/{fw.catalog_id(product)}-catalog.yaml",
        guidance_url=f"file://../guidance/{fw.key}-{product}-guidance.yaml",
        framework=fw, version=version,
    )
    r.check(not validate_policy(policy), "policy passes validate_policy()")
    r.check(policy["metadata"]["id"] == fw.policy_id(product),
            f"policy id is {fw.policy_id(product)!r}")
    plans = policy["adherence"]["assessment-plans"]
    r.check(len(plans) == len(rules),
            f"assessment-plans count matches extracted rules: {len(plans)}")

    # --- Round-trip accuracy ---------------------------------------------
    print("\n[5] Accuracy vs source")
    src_rules = {r_ for c in policy_obj.controls for r_ in (c.rules or []) if "=" not in r_}
    plan_ids = {p["id"] for p in plans}
    missing = src_rules - plan_ids
    r.check(not missing, f"all source rules appear as assessment-plans "
                         f"(missing {len(missing)})")

    # --- NIST guard -------------------------------------------------------
    print("\n[6] NIST code path still intact")
    nist = get_framework("nist")
    r.check(nist.catalog_id("rhel9") == "nist-800-53-rev5-rhel9",
            "NIST catalog id unchanged")
    r.check(nist.group_for("ac-2.5") == "ac", "NIST groups by family")

    print("\n" + "=" * 60)
    status = "FAILED" if r.failed else "OK"
    print(f"SUMMARY: {status} ({r.failed} failed)")
    print("=" * 60)
    sys.exit(1 if r.failed else 0)


if __name__ == "__main__":
    main()
