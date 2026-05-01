#!/usr/bin/env python3
"""
Generate a CIS-NIST profile based on the NIST 800-53 control file.

This script copies the existing CIS profile and changes the control file
reference from cis_rhelX:all to nist_800_53:all, while keeping all other
selections (exclusions, variable overrides, etc.) intact.

Usage:
  ./generate_nist_based_cis_profile.py --product rhel9
"""

import sys
from pathlib import Path
from typing import Dict, List
import argparse
import re

try:
    from ruamel.yaml import YAML
except ImportError:
    print("Error: ruamel.yaml is required. Install it with:", file=sys.stderr)
    print("  pip install ruamel.yaml", file=sys.stderr)
    sys.exit(1)


class NISTBasedCISProfileGenerator:
    """Generates NIST-based CIS profiles."""

    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.yaml = YAML()
        self.yaml.preserve_quotes = True
        self.yaml.default_flow_style = False
        self.yaml.indent(mapping=2, sequence=4, offset=2)
        self.yaml.width = 4096

    def load_cis_profile(self, product: str) -> Dict:
        """Load the existing CIS profile for a product."""
        cis_profile = self.repo_root / "products" / product / "profiles" / "cis.profile"

        if not cis_profile.exists():
            print(f"Error: CIS profile not found at {cis_profile}", file=sys.stderr)
            sys.exit(1)

        with open(cis_profile, 'r', encoding='utf-8') as f:
            return self.yaml.load(f)

    def generate_profile(self, product: str, output_file: Path):
        """Generate NIST-based CIS profile by copying CIS profile and changing control reference."""
        print(f"Generating NIST-based CIS profile for {product}...")

        # Load CIS profile
        cis_profile = self.load_cis_profile(product)

        # Copy the profile
        nist_profile = dict(cis_profile)

        # Update title to indicate NIST-based
        if 'title' in nist_profile:
            nist_profile['title'] = nist_profile['title'] + ' (NIST-based)'

        # Update description to mention NIST source
        if 'description' in nist_profile:
            version = nist_profile.get('metadata', {}).get('version', '2.0.0')
            product_number = product.replace('rhel', '')

            # Extract level from original description
            level_match = re.search(r'"([^"]+)"', nist_profile['description'])
            level_desc = level_match.group(1) if level_match else 'Level 2 - Server'

            nist_profile['description'] = f'''This profile defines a baseline that aligns to the "{level_desc}"
configuration from the Center for Internet Security® Red Hat Enterprise
Linux {product_number} Benchmark™, v{version}.

This profile is generated from the NIST 800-53 control file and uses
the unified NIST 800-53 controls that include CIS-derived rules and
variables from all RHEL versions.

This profile includes Center for Internet Security®
Red Hat Enterprise Linux {product_number} CIS Benchmarks™ content.'''

        # Update SMEs to indicate automation
        if 'metadata' not in nist_profile:
            nist_profile['metadata'] = {}
        nist_profile['metadata']['SMEs'] = ['nist_sync_automation']

        # Update selections: replace cis_rhelX:all with nist_800_53:all
        if 'selections' in nist_profile:
            new_selections = []
            replaced = False

            for selection in nist_profile['selections']:
                # Check if this is a CIS control file selection
                if isinstance(selection, str) and re.match(r'cis_rhel\d+:all', selection):
                    # Replace with NIST control file selection
                    new_selections.append('nist_800_53:all')
                    replaced = True
                    print(f"  Replaced: {selection} → nist_800_53:all")
                else:
                    # Keep all other selections (exclusions, variables, etc.)
                    new_selections.append(selection)

            nist_profile['selections'] = new_selections

            if not replaced:
                print("  Warning: No CIS control file selection found to replace", file=sys.stderr)

            # Count extra selections
            extra_count = len([s for s in new_selections if s != 'nist_800_53:all'])
            if extra_count > 0:
                print(f"  Kept {extra_count} extra selections from CIS profile:")
                for sel in [s for s in new_selections if s != 'nist_800_53:all']:
                    print(f"    - {sel}")

        # Write profile
        output_file.parent.mkdir(parents=True, exist_ok=True)
        with open(output_file, 'w', encoding='utf-8') as f:
            self.yaml.dump(nist_profile, f)

        print(f"  ✓ Profile saved to {output_file}")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Generate NIST-based CIS profile'
    )
    parser.add_argument(
        '--product',
        default='rhel9',
        help='Product ID (default: rhel9)'
    )
    parser.add_argument(
        '--output',
        type=Path,
        help='Output profile file (default: products/<product>/profiles/cis_nist.profile)'
    )
    parser.add_argument(
        '--repo-root',
        type=Path,
        default=Path(__file__).parent.parent.parent,
        help='Path to repository root (default: auto-detect)'
    )

    args = parser.parse_args()

    # Determine output file
    if args.output:
        output_file = args.output
    else:
        output_file = args.repo_root / "products" / args.product / "profiles" / "cis_nist.profile"

    generator = NISTBasedCISProfileGenerator(args.repo_root)

    try:
        generator.generate_profile(args.product, output_file)

        print("\n✓ Profile generation complete!")
        print("\nNext steps:")
        print(f"  1. Review the profile: {output_file}")
        print("  2. Build the product to test:")
        print(f"     ./build_product {args.product} --profile cis_nist --datastream-only")

        return 0

    except Exception as e:
        print(f"\n✗ Profile generation failed: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
