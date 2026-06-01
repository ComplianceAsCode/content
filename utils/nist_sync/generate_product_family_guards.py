#!/usr/bin/env python3
"""
Product Family-Aware Jinja2 Guard Generator

This script generates guards considering product families (e.g., all RHEL versions).
When targeting "rhel", it automatically includes rhel8, rhel9, rhel10.

Example:
  # Target all RHEL versions
  ./generate_product_family_guards.py --target rhel \
      --control-file controls/nist_800_53.yml

  # Target multiple families
  ./generate_product_family_guards.py --target rhel ocp \
      --control-file controls/nist_800_53.yml

Output generates smart guards:
  {{{% if product.startswith('rhel') %}}
  - sshd_disable_root_login
  {{{% endif %}}}
"""

import json
import sys
from pathlib import Path
from typing import Dict, Set, List, Optional
from collections import defaultdict
import re

try:
    from ruamel.yaml import YAML
except ImportError:
    print("Error: ruamel.yaml is required. Install it with:", file=sys.stderr)
    print("  pip install ruamel.yaml", file=sys.stderr)
    sys.exit(1)


# Product family definitions
PRODUCT_FAMILIES = {
    'rhel': ['rhel8', 'rhel9', 'rhel10'],
    'ol': ['ol7', 'ol8', 'ol9'],
    'ocp': ['ocp4'],
    'ubuntu': ['ubuntu2004', 'ubuntu2204', 'ubuntu2404'],
    'fedora': ['fedora'],
    'sle': ['sle12', 'sle15'],
    'rhcos': ['rhcos4'],
    'debian': ['debian10', 'debian11', 'debian12'],
    'almalinux': ['almalinux8', 'almalinux9'],
}


class ProductFamilyGuardGenerator:
    """Generates product family-aware guards for control files."""

    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.build_dir = repo_root / "build"

        # Setup YAML parser
        self.yaml = YAML()
        self.yaml.preserve_quotes = True
        self.yaml.default_flow_style = False
        self.yaml.indent(mapping=2, sequence=4, offset=2)
        self.yaml.width = 4096

    def expand_product_targets(self, targets: List[str]) -> List[str]:
        """
        Expand product family targets to specific products.

        Args:
            targets: List like ['rhel', 'ocp']

        Returns:
            Expanded list like ['rhel8', 'rhel9', 'rhel10', 'ocp4']
        """
        expanded = []

        for target in targets:
            target_lower = target.lower()

            if target_lower in PRODUCT_FAMILIES:
                # It's a family, expand it
                expanded.extend(PRODUCT_FAMILIES[target_lower])
            else:
                # It's a specific product
                expanded.append(target_lower)

        return sorted(set(expanded))

    def detect_product_family(self, products: Set[str]) -> Optional[str]:
        """
        Detect if a set of products forms a complete family.

        Args:
            products: Set of product IDs

        Returns:
            Family name if products form a complete family, None otherwise
        """
        products_set = set(p.lower() for p in products)

        for family, members in PRODUCT_FAMILIES.items():
            members_set = set(members)

            # Only use family guard if ALL members of the family are present
            if products_set == members_set:
                return family

        return None

    def find_built_products(self) -> List[str]:
        """Find all products that have been built."""
        if not self.build_dir.exists():
            print(f"Error: Build directory not found: {self.build_dir}", file=sys.stderr)
            print("Run ./build_product first to generate builds", file=sys.stderr)
            sys.exit(1)

        products = []
        for product_dir in self.build_dir.iterdir():
            if product_dir.is_dir() and (product_dir / "profiles").exists():
                products.append(product_dir.name)

        return sorted(products)

    def scan_product_profiles(self, product: str) -> Set[str]:
        """Scan all profiles for a product and collect all selected rules."""
        profiles_dir = self.build_dir / product / "profiles"

        if not profiles_dir.exists():
            return set()

        all_rules = set()

        for profile_file in profiles_dir.glob("*.profile"):
            try:
                with open(profile_file, 'r', encoding='utf-8') as f:
                    profile_data = json.load(f)

                selections = profile_data.get('selections', [])

                # Filter out variable assignments and exclusions
                rule_ids = {
                    sel for sel in selections
                    if '=' not in sel and not sel.startswith('!')
                }

                all_rules.update(rule_ids)

            except (json.JSONDecodeError, IOError) as e:
                print(f"Warning: Failed to read {profile_file}: {e}", file=sys.stderr)

        return all_rules

    def scan_cis_control_files(self, products: List[str]) -> Dict[str, Set[str]]:
        """Scan CIS control files to determine which products each item belongs to."""
        rule_to_products = defaultdict(set)

        for product in products:
            cis_file = self.repo_root / 'products' / product / 'controls' / f'cis_{product}.yml'

            if not cis_file.exists():
                continue

            try:
                with open(cis_file, 'r', encoding='utf-8') as f:
                    cis_data = self.yaml.load(f)

                for control in cis_data.get('controls', []):
                    for rule_id in control.get('rules', []):
                        rule_to_products[rule_id].add(product)

            except Exception as e:
                print(f"Warning: Failed to read {cis_file}: {e}", file=sys.stderr)

        return dict(rule_to_products)

    def build_rule_to_products_map(
        self,
        products: List[str],
        verbose: bool = False
    ) -> Dict[str, Set[str]]:
        """Build a mapping of rule IDs to the products they appear in."""
        print("Scanning CIS control files for product availability...")

        rule_to_products = defaultdict(set)

        # Scan CIS control files (source of truth for which items belong to which product)
        cis_mappings = self.scan_cis_control_files(products)
        for rule_id, prods in cis_mappings.items():
            rule_to_products[rule_id].update(prods)

        print(f"  ✓ Scanned {len(products)} products")
        print(f"  ✓ Found {len(rule_to_products)} unique rules/variables")

        return dict(rule_to_products)

    def generate_jinja_guard(
        self,
        products: Set[str],
        all_products: Set[str],
        use_family_guards: bool = True
    ) -> str:
        """
        Generate a Jinja2 conditional guard for a rule.

        Args:
            products: Set of products where this rule exists
            all_products: Set of all known products
            use_family_guards: Use product.startswith() for families

        Returns:
            Jinja2 conditional string or empty string if applies to all
        """
        # If rule applies to all products, no guard needed
        if products == all_products:
            return ""

        # If rule applies to no products, exclude it entirely
        if not products:
            return "EXCLUDE"

        # Try to detect if products form a family
        if use_family_guards:
            family = self.detect_product_family(products)

            if family:
                # Use family-based guard (double braces for YAML file guards)
                return '{{% if product.startswith("' + family + '") %}}'

        # Otherwise, generate explicit list (double braces for YAML file guards)
        products_list = sorted(products)

        if len(products_list) == 1:
            return '{{% if product == "' + products_list[0] + '" %}}'
        else:
            products_str = '", "'.join(products_list)
            return '{{% if product in ["' + products_str + '"] %}}'

    def load_variable_to_products_map(self) -> Dict[str, Set[str]]:
        """Load variable-to-products mapping from CIS control files."""
        var_map_file = self.repo_root / "utils" / "nist_sync" / "data" / "variable_to_products.json"

        if not var_map_file.exists():
            print(f"Warning: Variable map not found at {var_map_file}", file=sys.stderr)
            print("Variables will be included for all products", file=sys.stderr)
            return {}

        with open(var_map_file, 'r', encoding='utf-8') as f:
            var_map = json.load(f)

        # Convert lists to sets
        return {var: set(products) for var, products in var_map.items()}

    def _group_variable_variants(self, rules: List[str]) -> List[str]:
        """Group product-specific variable variants into conditional blocks."""
        from collections import defaultdict

        # Find variable variants (same base variable, different product-specific values)
        variants = defaultdict(list)
        regular_items = []

        for item in rules:
            if item.startswith('GUARD:') and '=' in item:
                # Extract variable name (before =)
                parts = item.split(':', 2)
                if len(parts) >= 3:
                    var_assignment = parts[2]
                    var_name = var_assignment.split('=')[0]
                    variants[var_name].append(item)
                else:
                    regular_items.append(item)
            else:
                regular_items.append(item)

        # Rebuild the list, grouping variants
        grouped_rules = []
        variant_groups_count = 0

        for item in rules:
            # Skip items that are part of a variant group (we'll add them back grouped)
            if item.startswith('GUARD:') and '=' in item:
                parts = item.split(':', 2)
                if len(parts) >= 3:
                    var_assignment = parts[2]
                    var_name = var_assignment.split('=')[0]

                    # Only process if this is the first occurrence of this variant
                    if var_name in variants and len(variants[var_name]) > 1:
                        # Add all variants for this variable as a special marker
                        grouped_rules.append(f"VARIANT_GROUP:{var_name}:{'|'.join(variants[var_name])}")
                        variant_groups_count += 1
                        # Remove from variants dict so we don't process it again
                        del variants[var_name]
                    elif var_name not in variants:
                        # Already processed or single variant
                        continue
                    else:
                        # Single variant, keep as-is
                        grouped_rules.append(item)
                        del variants[var_name]
                else:
                    grouped_rules.append(item)
            else:
                grouped_rules.append(item)

        self._variant_groups_count = variant_groups_count
        return grouped_rules

    def apply_guards_to_control_file(
        self,
        control_file: Path,
        rule_to_products: Dict[str, Set[str]],
        output_file: Optional[Path] = None,
        use_family_guards: bool = True,
        verbose: bool = False
    ):
        """Apply product guards to a control file."""
        if not control_file.exists():
            print(f"Error: Control file not found: {control_file}", file=sys.stderr)
            sys.exit(1)

        print(f"Loading control file: {control_file}")

        with open(control_file, 'r', encoding='utf-8') as f:
            control_data = self.yaml.load(f)

        # Load variable-to-products mapping
        var_to_products = self.load_variable_to_products_map()

        if not control_data or 'controls' not in control_data:
            print("Error: Invalid control file format", file=sys.stderr)
            sys.exit(1)

        all_products = set()
        for products in rule_to_products.values():
            all_products.update(products)

        guard_type = "family-based" if use_family_guards else "explicit"
        print(f"Applying {guard_type} product guards")
        print(f"  Products: {', '.join(sorted(all_products))}")

        total_rules = 0
        guarded_rules = 0
        excluded_rules = 0
        family_guards = 0
        grouped_variants = 0

        for control in control_data['controls']:
            if 'rules' not in control or not control['rules']:
                continue

            # Process each rule in the control
            new_rules = []
            has_unguarded_rules = False

            for rule_id in control['rules']:
                total_rules += 1

                # Check if this is a variable or a rule
                if '=' in rule_id:
                    # It's a variable - get products from variable map
                    products = var_to_products.get(rule_id, set())
                else:
                    # It's a rule - get products from rule map
                    products = rule_to_products.get(rule_id, set())

                # Generate guard
                guard = self.generate_jinja_guard(products, all_products, use_family_guards)

                if guard == "EXCLUDE":
                    if verbose:
                        print(f"  {control['id']}: Excluding {rule_id} (not in any product)")
                    excluded_rules += 1
                    continue

                elif guard:
                    guarded_rules += 1
                    if 'startswith' in guard:
                        family_guards += 1

                    if verbose:
                        products_str = ', '.join(sorted(products))
                        print(f"  {control['id']}: {rule_id} → {products_str}")
                        print(f"             Guard: {guard}")

                    # Store as marker for later conversion
                    new_rules.append(f"GUARD:{guard}:{rule_id}")

                else:
                    # Rule applies to all products
                    new_rules.append(rule_id)
                    has_unguarded_rules = True

            # Group product-specific variable variants
            new_rules = self._group_variable_variants(new_rules)
            if hasattr(self, '_variant_groups_count'):
                grouped_variants += self._variant_groups_count

            # If ALL rules are guarded AND there's only ONE unique guard,
            # mark to add else: []
            if new_rules and not has_unguarded_rules:
                # Count unique guards
                unique_guards = set()
                for rule in new_rules:
                    if isinstance(rule, str) and rule.startswith('GUARD:'):
                        parts = rule.split(':', 2)
                        if len(parts) >= 2:
                            unique_guards.add(parts[1])

                # Only add else: [] if there's exactly ONE guard
                if len(unique_guards) == 1:
                    control['_NEEDS_ELSE_EMPTY'] = True

            control['rules'] = new_rules

        print(f"  ✓ Processed {total_rules} rules")
        print(f"  ✓ Added guards to {guarded_rules} rules")
        if use_family_guards:
            print(f"  ✓ Used family guards for {family_guards} rules")
        if grouped_variants > 0:
            print(f"  ✓ Grouped {grouped_variants} variable variant groups")
        print(f"  ✓ Excluded {excluded_rules} rules (not in any product)")

        # Determine output path
        if output_file is None:
            output_file = control_file

        print(f"Writing guarded control file: {output_file}")

        # Count controls that need else: []
        controls_needing_else = sum(1 for c in control_data['controls'] if '_NEEDS_ELSE_EMPTY' in c)
        if controls_needing_else > 0:
            print(f"  ✓ Will add else: [] to {controls_needing_else} controls with all-guarded rules")

        # Write to file with custom formatting for guards
        self._write_guarded_yaml(control_data, output_file)

        print(f"  ✓ Saved to {output_file}")

    def _write_guarded_yaml(self, data: Dict, output_path: Path):
        """Write YAML with Jinja2 guards expanded."""
        import io

        # First, dump to string
        stream = io.StringIO()
        self.yaml.dump(data, stream)
        yaml_content = stream.getvalue()

        # Process to convert GUARD markers to Jinja2
        lines = yaml_content.split('\n')
        output_lines = []
        current_guard = None
        indent_level = 0
        current_control_needs_else = False
        in_rules_section = False

        for i, line in enumerate(lines):
            # Check if line contains a VARIANT_GROUP marker
            if 'VARIANT_GROUP:' in line:
                # Extract variable name and variant items
                parts = line.split('VARIANT_GROUP:', 1)[1]
                var_name_end = parts.index(':', 0)
                variants_str = parts[var_name_end + 1:].strip().strip("'\"")
                variants = variants_str.split('|')

                # Get indentation
                indent = len(line) - len(line.lstrip())

                # Close any existing guard
                if current_guard:
                    output_lines.append(' ' * indent_level + '{{% endif %}}')
                    current_guard = None

                # Generate if/elif block for variants
                for i, variant in enumerate(variants):
                    # Parse the variant (GUARD:condition:var_name=value)
                    if variant.startswith('GUARD:'):
                        v_parts = variant.split(':', 2)
                        if len(v_parts) >= 3:
                            guard_condition = v_parts[1]
                            var_assignment = v_parts[2]

                            if i == 0:
                                # First variant uses 'if'
                                output_lines.append(' ' * indent + guard_condition)
                            else:
                                # Subsequent variants use 'elif'
                                elif_condition = guard_condition.replace('{{% if ', '{{% elif ')
                                output_lines.append(' ' * indent + elif_condition)

                            # Add the variable assignment
                            output_lines.append(' ' * indent + f'- {var_assignment}')

                # Close the if/elif block
                output_lines.append(' ' * indent + '{{% endif %}}')

            # Check if line contains a GUARD marker (but not _CONTROL_GUARD)
            elif 'GUARD:' in line and '_CONTROL_GUARD:' not in line:
                # Extract guard and rule
                parts = line.split('GUARD:', 1)[1]
                try:
                    guard_end = parts.index(':', 0)
                    guard = parts[:guard_end]
                    rule_id = parts[guard_end + 1:].strip().strip("'\"")
                except ValueError:
                    print(f"Error parsing GUARD marker in line: {line}", file=sys.stderr)
                    print(f"Parts after split: {parts}", file=sys.stderr)
                    raise

                # Get indentation
                indent = len(line) - len(line.lstrip())

                # Close previous guard if different
                if current_guard and current_guard != guard:
                    output_lines.append(' ' * indent_level + '{{% endif %}}')
                    current_guard = None

                # Open new guard if needed
                if not current_guard:
                    output_lines.append(' ' * indent + guard)
                    indent_level = indent
                    current_guard = guard

                # Add the rule
                output_lines.append(' ' * indent + f'- {rule_id}')

            else:
                # Regular line
                stripped = line.lstrip()
                indent = len(line) - len(line.lstrip())

                # Check for control start (- id: at indentation 2)
                if stripped.startswith('- id:') and indent == 2:
                    current_control_needs_else = False
                    in_rules_section = False
                    # Look ahead for _NEEDS_ELSE_EMPTY marker
                    for j in range(i + 1, min(i + 20, len(lines))):
                        next_line = lines[j]
                        if '_NEEDS_ELSE_EMPTY:' in next_line:
                            current_control_needs_else = True
                            break
                        if next_line.lstrip().startswith('- id:'):
                            break

                # Skip marker lines
                if '_NEEDS_ELSE_EMPTY:' in line:
                    continue

                # Detect rules: section
                if stripped.startswith('rules:'):
                    in_rules_section = True

                # Check if this is a plain rule (starts with '- ' but no GUARD marker)
                is_plain_rule = stripped.startswith('- ') and 'GUARD:' not in line and 'VARIANT_GROUP:' not in line

                # Close guard if:
                # 1. We're moving to a different section (not a list item), OR
                # 2. We encounter a plain rule (should not be inside a guard)
                if current_guard and line:
                    if not line.startswith(' ' * indent_level + '- ') or is_plain_rule:
                        # Check if we're exiting the rules section
                        exiting_rules = in_rules_section and not (stripped.startswith('- ') or stripped.startswith('{'))

                        # Before closing, check if we need to add else: []
                        if current_control_needs_else and exiting_rules:
                            # Add else: [] at the same indentation as the rules
                            output_lines.append(' ' * indent_level + '{{% else %}}')
                            output_lines.append(' ' * indent_level + '[]')
                            output_lines.append(' ' * indent_level + '{{% endif %}}')
                        else:
                            # Regular endif
                            output_lines.append(' ' * indent_level + '{{% endif %}}')
                        current_guard = None

                        # Mark that we've exited the rules section
                        if exiting_rules:
                            in_rules_section = False

                output_lines.append(line)

        # Close final guard if needed
        if current_guard:
            # If we're still in rules section and control needs else, add it
            if in_rules_section and current_control_needs_else:
                output_lines.append(' ' * indent_level + '{{% else %}}')
                output_lines.append(' ' * indent_level + '[]')
            output_lines.append(' ' * indent_level + '{{% endif %}}')

        # Write output
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(output_lines))


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Generate product family-aware Jinja2 guards for control files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Product Families:
  rhel     → rhel8, rhel9, rhel10
  ol       → ol7, ol8, ol9
  ocp      → ocp4
  ubuntu   → ubuntu2004, ubuntu2204, ubuntu2404
  fedora   → fedora
  sle      → sle12, sle15
  rhcos    → rhcos4
  debian   → debian10, debian11, debian12
  almalinux → almalinux8, almalinux9

Examples:
  # Target all RHEL versions (uses defaults: .source → .yml)
  %(prog)s --target rhel

  # Target RHEL and OCP families
  %(prog)s --target rhel ocp

  # Target specific products
  %(prog)s --target rhel8 rhel9 ocp4

  # Use explicit guards instead of family guards
  %(prog)s --target rhel --no-family-guards

  # Custom input/output files
  %(prog)s --target rhel --control-file custom.yml.source --output custom.yml

Output example with family guards:
  {{{% if product.startswith('rhel') %}
  - sshd_disable_root_login
  {{{% endif %}}
        '''
    )
    parser.add_argument(
        '--target',
        nargs='+',
        required=True,
        help='Target product families or specific products (e.g., rhel ocp)'
    )
    parser.add_argument(
        '--control-file',
        type=Path,
        help='Path to source control file to process (default: controls/nist_800_53.yml.source)'
    )
    parser.add_argument(
        '--output',
        type=Path,
        help='Output file path (default: controls/nist_800_53.yml)'
    )
    parser.add_argument(
        '--repo-root',
        type=Path,
        default=Path(__file__).parent.parent.parent,
        help='Path to repository root (default: auto-detect)'
    )
    parser.add_argument(
        '--no-family-guards',
        action='store_true',
        help='Use explicit product lists instead of family-based guards'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )

    args = parser.parse_args()

    # Set defaults for source/output files
    if not args.control_file:
        args.control_file = args.repo_root / "controls" / "nist_800_53.yml.source"
    if not args.output:
        args.output = args.repo_root / "controls" / "nist_800_53.yml"

    generator = ProductFamilyGuardGenerator(args.repo_root)

    try:
        # Expand family targets to specific products
        products = generator.expand_product_targets(args.target)

        print(f"Target families/products: {', '.join(args.target)}")
        print(f"Expanded to products: {', '.join(products)}")
        print()

        # Build rule→products mapping
        rule_to_products = generator.build_rule_to_products_map(
            products,
            verbose=args.verbose
        )

        print()

        # Apply guards to control file
        generator.apply_guards_to_control_file(
            args.control_file,
            rule_to_products,
            output_file=args.output,
            use_family_guards=not args.no_family_guards,
            verbose=args.verbose
        )

        print()
        print("✓ Product family guards generated successfully!")

        return 0

    except Exception as e:
        print(f"\n✗ Failed to generate guards: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
