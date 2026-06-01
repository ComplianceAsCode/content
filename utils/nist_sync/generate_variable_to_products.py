#!/usr/bin/env python3
"""
Generate variable-to-products mapping from CIS control files.

This script scans CIS control files for each RHEL version and builds
a mapping of which products use which variable assignments.

Usage:
  ./generate_variable_to_products.py
"""

import json
import sys
from pathlib import Path
from collections import defaultdict
from typing import Dict, Set

try:
    from ruamel.yaml import YAML
except ImportError:
    print("Error: ruamel.yaml is required. Install it with:", file=sys.stderr)
    print("  pip install ruamel.yaml", file=sys.stderr)
    sys.exit(1)


class VariableToProductsGenerator:
    """Generates variable-to-products mapping from CIS control files."""

    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.yaml = YAML()
        self.yaml.preserve_quotes = True

    def extract_variables_from_controls(self, controls) -> Set[str]:
        """
        Recursively extract variable assignments from control structure.

        Returns set of variable assignments like "var_name=value"
        """
        variables = set()

        def traverse(obj):
            if isinstance(obj, dict):
                # Check for rules (variable assignments in CIS control files)
                rules = obj.get('rules', [])
                for rule in rules:
                    if isinstance(rule, str) and '=' in rule and not rule.startswith('!'):
                        # This is a variable assignment
                        variables.add(rule)

                # Check for selections (variable assignments in profile files)
                selections = obj.get('selections', [])
                for sel in selections:
                    if isinstance(sel, str) and '=' in sel and not sel.startswith('!'):
                        # This is a variable assignment
                        variables.add(sel)

                # Recurse into nested controls
                nested_controls = obj.get('controls', [])
                if nested_controls:
                    traverse(nested_controls)

                # Recurse into other dict values
                for value in obj.values():
                    if isinstance(value, (dict, list)):
                        traverse(value)

            elif isinstance(obj, list):
                for item in obj:
                    if isinstance(item, (dict, list)):
                        traverse(item)

        traverse(controls)
        return variables

    def scan_cis_control_file(self, product: str) -> Set[str]:
        """Scan CIS control file for a product and extract variable assignments."""
        cis_file = self.repo_root / "products" / product / "controls" / f"cis_{product}.yml"

        if not cis_file.exists():
            print(f"Warning: CIS control file not found: {cis_file}", file=sys.stderr)
            return set()

        print(f"Scanning {product}...")

        with open(cis_file, 'r', encoding='utf-8') as f:
            data = self.yaml.load(f)

        # Extract variables from all controls
        controls = data.get('controls', [])
        variables = self.extract_variables_from_controls(controls)

        print(f"  Found {len(variables)} variable assignments")
        return variables

    def build_variable_to_products_map(self, products: list) -> Dict[str, list]:
        """Build mapping of variable assignments to products that use them."""
        var_to_products = defaultdict(set)

        for product in products:
            variables = self.scan_cis_control_file(product)
            for var in variables:
                var_to_products[var].add(product)

        # Convert to dict with sorted lists
        result = {
            var: sorted(list(prods))
            for var, prods in sorted(var_to_products.items())
        }

        return result

    def save_mapping(self, mapping: Dict[str, list], output_file: Path):
        """Save mapping to JSON file."""
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(mapping, f, indent=2, sort_keys=True)

        print(f"\n✓ Saved variable-to-products mapping to {output_file}")
        print(f"  Total variables: {len(mapping)}")

        # Show statistics
        all_products = set()
        for prods in mapping.values():
            all_products.update(prods)
        print(f"  Products found: {', '.join(sorted(all_products))}")


def main():
    """Main entry point."""
    repo_root = Path(__file__).parent.parent.parent
    products = ['rhel8', 'rhel9', 'rhel10']

    output_file = repo_root / "utils" / "nist_sync" / "data" / "variable_to_products.json"

    print("Generating variable-to-products mapping from CIS control files...")
    print()

    generator = VariableToProductsGenerator(repo_root)

    try:
        # Build mapping
        mapping = generator.build_variable_to_products_map(products)

        # Save to file
        generator.save_mapping(mapping, output_file)

        print("\n✓ Generation complete!")
        return 0

    except Exception as e:
        print(f"\n✗ Generation failed: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
