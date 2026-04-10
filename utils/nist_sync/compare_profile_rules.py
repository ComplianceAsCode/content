#!/usr/bin/env python3
"""
Compare rules between CIS profile and NIST-based CIS profile.

This script verifies that the NIST-based CIS profile produces the same
set of rules and variables as the original CIS profile.

Usage:
  ./compare_profile_rules.py --product rhel9 --cis-level l2_server
"""

import sys
from pathlib import Path
from typing import Dict, List, Set
import argparse

try:
    from ruamel.yaml import YAML
except ImportError:
    print("Error: ruamel.yaml is required. Install it with:", file=sys.stderr)
    print("  pip install ruamel.yaml", file=sys.stderr)
    sys.exit(1)


class ProfileComparator:
    """Compares rules between CIS and NIST-based profiles."""

    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.yaml = YAML()
        self.yaml.preserve_quotes = True
        self.yaml.default_flow_style = False

    def load_control_file(self, control_file: Path) -> Dict:
        """Load a control file."""
        with open(control_file, 'r', encoding='utf-8') as f:
            return self.yaml.load(f)

    def get_rules_from_cis_controls(
        self,
        product: str,
        cis_level: str
    ) -> tuple[Set[str], Set[str]]:
        """Get rules and variables from CIS control file for a specific level."""
        cis_file = self.repo_root / "products" / product / "controls" / f"cis_{product}.yml"

        if not cis_file.exists():
            print(f"Error: CIS control file not found at {cis_file}", file=sys.stderr)
            sys.exit(1)

        cis_data = self.load_control_file(cis_file)

        # Map level to list (handle inheritance)
        levels_to_include = set()
        if cis_level in ['l2_server', 'l2_workstation']:
            # L2 includes L1
            levels_to_include.add(cis_level)
            base_level = 'l1_server' if 'server' in cis_level else 'l1_workstation'
            levels_to_include.add(base_level)
        else:
            levels_to_include.add(cis_level)

        rules = set()
        variables = set()

        for control in cis_data.get('controls', []):
            control_levels = control.get('levels', [])

            # Check if control applies to any of the levels we're including
            if any(level in control_levels for level in levels_to_include):
                for rule in control.get('rules', []):
                    if '=' in rule:
                        variables.add(rule)
                    else:
                        rules.add(rule)

        return rules, variables

    def get_rules_from_nist_controls(
        self,
        nist_control_ids: List[str]
    ) -> tuple[Set[str], Set[str]]:
        """Get rules and variables from NIST control file for given control IDs."""
        nist_file = self.repo_root / "controls" / "nist_800_53.yml"

        if not nist_file.exists():
            print(f"Error: NIST control file not found at {nist_file}", file=sys.stderr)
            sys.exit(1)

        nist_data = self.load_control_file(nist_file)

        # Create lookup by control ID
        controls_by_id = {
            ctrl['id']: ctrl
            for ctrl in nist_data.get('controls', [])
        }

        rules = set()
        variables = set()

        for ctrl_id in nist_control_ids:
            if ctrl_id in controls_by_id:
                control = controls_by_id[ctrl_id]
                for rule in control.get('rules', []):
                    if '=' in rule:
                        variables.add(rule)
                    else:
                        rules.add(rule)

        return rules, variables

    def get_nist_profile_selections(self, product: str) -> List[str]:
        """Get control selections from NIST-based profile."""
        profile_file = self.repo_root / "products" / product / "profiles" / "cis_nist.profile"

        if not profile_file.exists():
            print(f"Error: NIST-based profile not found at {profile_file}", file=sys.stderr)
            print("Run generate_nist_based_cis_profile.py first", file=sys.stderr)
            sys.exit(1)

        with open(profile_file, 'r', encoding='utf-8') as f:
            profile_data = self.yaml.load(f)

        # Extract control IDs from selections
        control_ids = []
        for selection in profile_data.get('selections', []):
            if selection.startswith('nist_800_53:'):
                ctrl_id = selection.split(':', 1)[1]
                control_ids.append(ctrl_id)

        return control_ids

    def compare(self, product: str, cis_level: str):
        """Compare CIS and NIST-based profiles."""
        print(f"Comparing CIS and NIST-based profiles for {product} ({cis_level})...")
        print()

        # Get rules from CIS control file
        print("Analyzing CIS control file...")
        cis_rules, cis_vars = self.get_rules_from_cis_controls(product, cis_level)
        print(f"  Found {len(cis_rules)} rules and {len(cis_vars)} variables")

        # Get rules from NIST-based profile
        print("\nAnalyzing NIST-based profile...")
        nist_control_ids = self.get_nist_profile_selections(product)
        print(f"  Profile includes {len(nist_control_ids)} control selections")

        nist_rules, nist_vars = self.get_rules_from_nist_controls(nist_control_ids)
        print(f"  Found {len(nist_rules)} rules and {len(nist_vars)} variables")

        # Compare
        print("\n" + "=" * 60)
        print("COMPARISON RESULTS")
        print("=" * 60)

        # Rules comparison
        print(f"\nRules:")
        print(f"  CIS:  {len(cis_rules)}")
        print(f"  NIST: {len(nist_rules)}")

        missing_in_nist = cis_rules - nist_rules
        extra_in_nist = nist_rules - cis_rules

        if missing_in_nist:
            print(f"\n  ⚠  {len(missing_in_nist)} rules in CIS but NOT in NIST profile:")
            for rule in sorted(missing_in_nist)[:10]:
                print(f"     - {rule}")
            if len(missing_in_nist) > 10:
                print(f"     ... and {len(missing_in_nist) - 10} more")

        if extra_in_nist:
            print(f"\n  ⚠  {len(extra_in_nist)} rules in NIST but NOT in CIS profile:")
            for rule in sorted(extra_in_nist)[:10]:
                print(f"     - {rule}")
            if len(extra_in_nist) > 10:
                print(f"     ... and {len(extra_in_nist) - 10} more")

        if not missing_in_nist and not extra_in_nist:
            print("  ✓ Rules match perfectly!")

        # Variables comparison
        print(f"\nVariables:")
        print(f"  CIS:  {len(cis_vars)}")
        print(f"  NIST: {len(nist_vars)}")

        missing_vars_in_nist = cis_vars - nist_vars
        extra_vars_in_nist = nist_vars - cis_vars

        if missing_vars_in_nist:
            print(f"\n  ⚠  {len(missing_vars_in_nist)} variables in CIS but NOT in NIST profile:")
            for var in sorted(missing_vars_in_nist)[:10]:
                print(f"     - {var}")
            if len(missing_vars_in_nist) > 10:
                print(f"     ... and {len(missing_vars_in_nist) - 10} more")

        if extra_vars_in_nist:
            print(f"\n  ⚠  {len(extra_vars_in_nist)} variables in NIST but NOT in CIS profile:")
            for var in sorted(extra_vars_in_nist)[:10]:
                print(f"     - {var}")
            if len(extra_vars_in_nist) > 10:
                print(f"     ... and {len(extra_vars_in_nist) - 10} more")

        if not missing_vars_in_nist and not extra_vars_in_nist:
            print("  ✓ Variables match perfectly!")

        # Overall result
        print("\n" + "=" * 60)
        if not missing_in_nist and not extra_in_nist and not missing_vars_in_nist and not extra_vars_in_nist:
            print("✓ Profiles are equivalent!")
            return 0
        else:
            total_diff = len(missing_in_nist) + len(extra_in_nist) + len(missing_vars_in_nist) + len(extra_vars_in_nist)
            print(f"⚠  Profiles differ by {total_diff} items")
            return 1


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Compare CIS and NIST-based profiles'
    )
    parser.add_argument(
        '--product',
        default='rhel9',
        help='Product ID (default: rhel9)'
    )
    parser.add_argument(
        '--cis-level',
        default='l2_server',
        choices=['l1_server', 'l2_server', 'l1_workstation', 'l2_workstation'],
        help='CIS level to compare (default: l2_server)'
    )
    parser.add_argument(
        '--repo-root',
        type=Path,
        default=Path(__file__).parent.parent.parent,
        help='Path to repository root (default: auto-detect)'
    )

    args = parser.parse_args()

    comparator = ProfileComparator(args.repo_root)

    try:
        return comparator.compare(args.product, args.cis_level)
    except Exception as e:
        print(f"\n✗ Comparison failed: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
