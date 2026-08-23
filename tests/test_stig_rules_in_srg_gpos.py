#!/usr/bin/env python3
import argparse
from pathlib import Path
import sys

import ssg.environment
import ssg.controls


SSG_ROOT = Path(__file__).resolve().parent.parent


def _is_rule(selection: str) -> bool:
    return "=" not in selection


def _get_env_yaml(ssg_root: Path, product: str) -> dict:
    return ssg.environment.open_environment(
        str(ssg_root / "build" / "build_config.yml"),
        str(ssg_root / "products" / product / "product.yml"),
        str(ssg_root / "product_properties"))


def get_rules_in_srg_gpos(ssg_root: Path, product: str) -> set:
    env_yaml = _get_env_yaml(ssg_root, product)
    mgr = ssg.controls.ControlsManager(
        [str(ssg_root / "controls")], env_yaml)
    mgr.load()
    return {
        rule
        for control in mgr.get_all_controls("srg_gpos")
        for rule in control.rules
        if _is_rule(rule)
    }


def get_rules_in_stig_profile(ssg_root: Path, product: str) -> set:
    profile_path = (
        ssg_root / "tests" / "data" / "profile_stability" / product
        / "stig.profile")
    lines = profile_path.read_text().splitlines()
    return {line.strip() for line in lines if _is_rule(line.strip())}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-r", "--root", type=Path, default=SSG_ROOT,
        help="Path to the root of the content repo")
    parser.add_argument(
        "-p", "--product", required=True, type=str,
        help="Product ID")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    rules_in_stig_profile = get_rules_in_stig_profile(args.root, args.product)
    rules_in_srg_gpos = get_rules_in_srg_gpos(args.root, args.product)
    missing = rules_in_stig_profile - rules_in_srg_gpos
    if missing:
        print("These rules are part of profile but aren't part of SRG GPOS:")
        for rule in sorted(missing):
            print(rule)
        sys.exit(1)
