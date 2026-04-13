#!/usr/bin/env python3
"""
NIST 800-53 Split Control File Synchronization (Product-Specific)

Generates product-specific NIST 800-53 control files in SPLIT-BY-FAMILY format:
  - shared/references/controls/nist_800_53_cis_reference_{product}.yml (top-level metadata)
  - shared/references/controls/nist_800_53_cis_reference_{product}/*.yml (family files)

Each product (rhel8, rhel9, rhel10) gets its own control file set with only
rules/variables available for that specific product. No Jinja2 guards needed.

OSCAL metadata (description, parameters, guidance, related_controls) is NOT
included in control files. This data can be retrieved separately from the
OSCAL catalog when needed (e.g., for web application display).

The split format is supported natively by the build system:
  - Policy class loads from directory if it exists
  - Automatically merges all .yml files in the directory
  - See: ssg/controls.py:661-662

Architecture:
  1. Load CIS control file for specific product
  2. Generate control data from OSCAL catalog (structure only, no metadata)
  3. Filter rules/variables to only those available for target product
  4. Split by control family (AC, AU, CM, etc.)
  5. Write product-specific top-level metadata file
  6. Write product-specific family files
"""

import io
import json
import sys
from pathlib import Path
from typing import Dict, List, Set
from collections import defaultdict
from ruamel.yaml.scalarstring import LiteralScalarString

try:
    from ruamel.yaml import YAML
except ImportError:
    print("Error: ruamel.yaml is required", file=sys.stderr)
    sys.exit(1)


class NISTSplitSync:
    """Synchronizes NIST 800-53 controls in split-by-family format."""

    # NIST 800-53 Rev 5 control families
    FAMILIES = {
        'ac': 'Access Control',
        'at': 'Awareness and Training',
        'au': 'Audit and Accountability',
        'ca': 'Assessment, Authorization, and Monitoring',
        'cm': 'Configuration Management',
        'cp': 'Contingency Planning',
        'ia': 'Identification and Authentication',
        'ir': 'Incident Response',
        'ma': 'Maintenance',
        'mp': 'Media Protection',
        'pe': 'Physical and Environmental Protection',
        'pl': 'Planning',
        'pm': 'Program Management',
        'ps': 'Personnel Security',
        'pt': 'PII Processing and Transparency',
        'ra': 'Risk Assessment',
        'sa': 'System and Services Acquisition',
        'sc': 'System and Communications Protection',
        'si': 'System and Information Integrity',
        'sr': 'Supply Chain Risk Management',
        'other': 'CIS Items Without NIST Mapping',
    }

    def __init__(self, repo_root: Path, product: str = None, mode='reference', flat_structure=False):
        """
        Initialize syncer.

        Args:
            repo_root: Repository root path
            product: Target product (rhel8, rhel9, rhel10, etc.)
            mode: 'reference' (auto-generated) or 'real' (human-maintained)
            flat_structure: If True, save family files in same directory with prefix
        """
        self.repo_root = repo_root
        self.product = product
        self.mode = mode
        self.flat_structure = flat_structure
        self.data_dir = repo_root / "utils" / "nist_sync" / "data"

        # Set paths based on mode and product
        if mode == 'reference':
            if product:
                self.top_level_file = repo_root / "shared" / "references" / "controls" / f"nist_800_53_cis_reference_{product}.yml"
                self.family_dir = repo_root / "shared" / "references" / "controls" / f"nist_800_53_cis_reference_{product}"
                self.file_prefix = ""
            else:
                # Legacy non-product-specific reference (deprecated)
                self.top_level_file = repo_root / "shared" / "references" / "controls" / "nist_800_53_cis_reference.yml"
                if flat_structure:
                    self.family_dir = repo_root / "shared" / "references" / "controls"
                    self.file_prefix = "nist_800_53_cis_reference_"
                else:
                    self.family_dir = repo_root / "shared" / "references" / "controls" / "nist_800_53_cis_reference"
                    self.file_prefix = ""
        else:  # mode == 'real'
            if product:
                # Product-specific real files (in products/{product}/controls/)
                product_dir = repo_root / "products" / product / "controls"
                self.top_level_file = product_dir / "nist_800_53.yml"
                self.family_dir = product_dir / "nist_800_53"
                self.file_prefix = ""
            else:
                # Legacy global real files (deprecated)
                self.top_level_file = repo_root / "controls" / "nist_800_53.yml"
                if flat_structure:
                    self.family_dir = repo_root / "controls"
                    self.file_prefix = "nist_800_53_"
                else:
                    self.family_dir = repo_root / "controls" / "nist_800_53"
                    self.file_prefix = ""

        # YAML handler
        self.yaml = YAML()
        self.yaml.preserve_quotes = False
        self.yaml.default_flow_style = False
        self.yaml.width = 99
        self.yaml.indent(mapping=2, sequence=4, offset=2)

    def extract_family(self, control_id: str) -> str:
        """Extract family prefix from control ID."""
        if '-' not in control_id:
            return 'other'
        family = control_id.split('-')[0].lower()
        return family if family in self.FAMILIES else 'other'

    def load_oscal_catalog(self) -> Dict:
        """Load NIST OSCAL catalog."""
        catalog_file = self.data_dir / "nist_800_53_rev5_catalog.json"
        with open(catalog_file, 'r') as f:
            return json.load(f)

    def load_baselines(self) -> Dict[str, Set[str]]:
        """Load LOW/MODERATE/HIGH baselines."""
        baselines = {'low': set(), 'moderate': set(), 'high': set()}

        for level in ['low', 'moderate', 'high']:
            filepath = self.data_dir / f"nist_800_53_rev5_{level}_baseline.json"
            if not filepath.exists():
                continue

            with open(filepath, 'r') as f:
                data = json.load(f)

            # Extract control IDs from imports
            for imp in data.get('profile', {}).get('imports', []):
                for inc in imp.get('include-controls', []):
                    if 'with-ids' in inc:
                        baselines[level].update(inc['with-ids'])

        return baselines

    def load_all_cis_items_from_control_files(self) -> Set[str]:
        """Scan CIS control files to find all CIS rules/variables for specified product.

        Returns:
            Set of rule/variable names (variables have values stripped: var_name=value → var_name)
        """
        all_items = set()

        # If product is specified, only load from that product
        products = [self.product] if self.product else ['rhel8', 'rhel9', 'rhel10']

        for product in products:
            control_file = self.repo_root / "products" / product / "controls" / f"cis_{product}.yml"
            if not control_file.exists():
                continue

            with open(control_file) as f:
                data = self.yaml.load(f)

            def extract_rules(controls):
                """Recursively extract rules from controls."""
                for ctrl in controls:
                    if 'rules' in ctrl:
                        for rule in ctrl['rules']:
                            # Handle both "rule_id" and "var_name=value" formats
                            if '=' in rule:
                                rule_id = rule.split('=')[0]
                            else:
                                rule_id = rule.lstrip('!')  # Remove exclusion prefix
                            all_items.add(rule_id)

                    # Recursively process nested controls
                    if 'controls' in ctrl:
                        extract_rules(ctrl['controls'])

            extract_rules(data.get('controls', []))

        return all_items

    def load_all_cis_items_with_values(self) -> Dict[str, Set[str]]:
        """Scan CIS control files to find all rules/variables WITH their assigned values for specified product.

        Returns:
            Dict mapping variable/rule name to set of full assignments (e.g., {'var_x': {'var_x=1', 'var_x=2'}})
        """
        items_with_values = defaultdict(set)

        # If product is specified, only load from that product
        products = [self.product] if self.product else ['rhel8', 'rhel9', 'rhel10']

        for product in products:
            control_file = self.repo_root / "products" / product / "controls" / f"cis_{product}.yml"
            if not control_file.exists():
                continue

            with open(control_file) as f:
                data = self.yaml.load(f)

            def extract_rules(controls):
                """Recursively extract rules from controls."""
                for ctrl in controls:
                    if 'rules' in ctrl:
                        for rule in ctrl['rules']:
                            rule = rule.lstrip('!')  # Remove exclusion prefix
                            if '=' in rule:
                                # Variable assignment: store both the name and full assignment
                                var_name = rule.split('=')[0]
                                items_with_values[var_name].add(rule)
                            else:
                                # Regular rule: store as-is
                                items_with_values[rule].add(rule)

                    # Recursively process nested controls
                    if 'controls' in ctrl:
                        extract_rules(ctrl['controls'])

            extract_rules(data.get('controls', []))

        return items_with_values

    def load_cis_mappings(self) -> tuple:
        """Load CIS→NIST mappings and invert to NIST→CIS."""
        mapping_file = self.data_dir / "cis_nist_mappings.json"

        if not mapping_file.exists():
            print(f"  No CIS mappings found at {mapping_file}")
            return {}, {}, set()

        with open(mapping_file, 'r') as f:
            data = json.load(f)

        # Handle existing format: {"rules": {...}, "variables": {...}}
        rule_to_nist = {}
        var_to_nist = {}

        if 'rules' in data and 'variables' in data:
            # New format
            rule_to_nist = data['rules']
            var_to_nist = data['variables']
        elif 'rules' in data:
            # Old format (rules only)
            rule_to_nist = data['rules']
        else:
            # Very old format (direct dict)
            rule_to_nist = data

        # Invert: rule→nist to nist→rules
        nist_to_rules = defaultdict(set)
        nist_to_vars = defaultdict(set)
        mapped_items = set()

        for rule_id, nist_controls in rule_to_nist.items():
            mapped_items.add(rule_id)
            for nist_id in nist_controls:
                nist_to_rules[nist_id].add(rule_id)

        for var_id, nist_controls in var_to_nist.items():
            mapped_items.add(var_id)
            for nist_id in nist_controls:
                nist_to_vars[nist_id].add(var_id)

        return nist_to_rules, nist_to_vars, mapped_items

    @staticmethod
    def escape_jinja_syntax(text: str) -> str:
        """Replace {{ }} with [[ ]] to avoid Jinja2 macro expansion conflicts."""
        if not text:
            return text
        return text.replace('{{', '[[').replace('}}', ']]')

    def extract_statement(self, parts: List[Dict], indent=0) -> str:
        """Extract and format control statement from OSCAL parts."""
        lines = []

        for part in parts:
            if part.get('name') == 'statement':
                # Top-level statement
                if 'prose' in part:
                    lines.append(self.escape_jinja_syntax(part['prose']))

                # Process sub-parts (a, b, c, etc.)
                if 'parts' in part:
                    for subpart in part['parts']:
                        label = subpart.get('id', '')
                        prose = subpart.get('prose', '')

                        # Extract the letter/number from id (e.g., "ac-2_smt.a" → "a")
                        if label and '.' in label:
                            label = label.split('.')[-1]

                        if label and prose:
                            lines.append(f"  {label}. {self.escape_jinja_syntax(prose)}")
                        elif prose:
                            lines.append(f"  {self.escape_jinja_syntax(prose)}")

                        # Handle nested sub-parts (a.1, a.2, etc.)
                        if 'parts' in subpart:
                            for nested in subpart['parts']:
                                nested_label = nested.get('id', '').split('.')[-1]
                                nested_prose = nested.get('prose', '')
                                if nested_label and nested_prose:
                                    lines.append(f"    {nested_label}. {self.escape_jinja_syntax(nested_prose)}")

        return '\n'.join(lines) if lines else ''

    def extract_parameters(self, ctrl_data: Dict) -> List[Dict]:
        """Extract organization-defined parameters (ODPs) from control."""
        parameters = []

        for param in ctrl_data.get('params', []):
            param_info = {
                'id': param.get('id', ''),
                'label': self.escape_jinja_syntax(param.get('label', ''))
            }

            # Extract guidelines/constraints if available
            if 'guidelines' in param:
                guidelines = []
                for guideline in param['guidelines']:
                    if 'prose' in guideline:
                        guidelines.append(self.escape_jinja_syntax(guideline['prose']))
                if guidelines:
                    param_info['guidelines'] = guidelines

            # Extract select options if available
            if 'select' in param:
                select = param['select']
                if 'choice' in select:
                    param_info['choices'] = [self.escape_jinja_syntax(c) for c in select['choice']]

            parameters.append(param_info)

        return parameters

    def extract_guidance(self, parts: List[Dict]) -> str:
        """Extract guidance/discussion text from control."""
        for part in parts:
            if part.get('name') == 'guidance' and 'prose' in part:
                return self.escape_jinja_syntax(part['prose'])
        return ''

    def extract_related_controls(self, links: List[Dict]) -> List[str]:
        """Extract related control references."""
        related = []
        for link in links:
            if link.get('rel') == 'related' and 'href' in link:
                # Extract control ID from href (e.g., "#ac-3" → "ac-3")
                ctrl_id = link['href'].replace('#', '').lower()
                related.append(ctrl_id)
        return related

    def extract_controls_from_catalog(self, catalog: Dict) -> List[Dict]:
        """Extract all controls with full OSCAL metadata from catalog."""
        controls = []

        def process_control(ctrl_data, parent_id=None):
            """Recursively process controls and enhancements."""
            ctrl_id = ctrl_data.get('id', '').lower()
            title = ctrl_data.get('title', '')

            control = {
                'id': ctrl_id,
                'title': title
            }

            # Extract full statement (with all sub-parts a, b, c, etc.)
            parts = ctrl_data.get('parts', [])
            statement = self.extract_statement(parts)
            if statement:
                control['description'] = statement

            # Extract parameters (ODPs - Organization-Defined Parameters)
            parameters = self.extract_parameters(ctrl_data)
            if parameters:
                control['parameters'] = parameters

            # Extract guidance
            guidance = self.extract_guidance(parts)
            if guidance:
                control['guidance'] = guidance

            # Extract related controls
            links = ctrl_data.get('links', [])
            related = self.extract_related_controls(links)
            if related:
                control['related_controls'] = related

            controls.append(control)

            # Process enhancements (sub-controls)
            for subctrl in ctrl_data.get('controls', []):
                process_control(subctrl, parent_id=ctrl_id)

        # Process top-level controls and groups
        for group in catalog.get('catalog', {}).get('groups', []):
            for ctrl in group.get('controls', []):
                process_control(ctrl)

        return controls

    def generate_controls(self, verbose=False) -> Dict:
        """Generate control data from OSCAL + CIS mappings."""
        print("Phase 1: Loading OSCAL catalog and baselines...")
        catalog = self.load_oscal_catalog()
        baselines = self.load_baselines()
        print(f"  Found {sum(len(b) for b in baselines.values())} total baseline assignments")

        print("Phase 2: Loading CIS mappings...")
        nist_to_rules, nist_to_vars, mapped_items = self.load_cis_mappings()
        print(f"  Loaded {len(nist_to_rules)} rule mappings, {len(nist_to_vars)} variable mappings")

        print("Phase 3: Scanning CIS control files for product-specific rules...")
        all_cis_items = self.load_all_cis_items_from_control_files()
        all_cis_items_with_values = self.load_all_cis_items_with_values()
        product_info = f" for {self.product}" if self.product else " across all products"
        print(f"  Found {len(all_cis_items)} total CIS rules/variables{product_info}")
        print(f"  Items WITH NIST mappings: {len(mapped_items)}")
        print(f"  Items WITHOUT NIST mappings: {len(all_cis_items - mapped_items)}")

        print("Phase 4: Extracting controls from OSCAL...")
        oscal_controls = self.extract_controls_from_catalog(catalog)
        print(f"  Found {len(oscal_controls)} controls in catalog")

        print("Phase 5: Building control data...")
        controls_by_family = defaultdict(list)

        for ctrl in oscal_controls:
            ctrl_id = ctrl['id']

            # Determine minimum applicable level (inheritance handles the rest:
            # moderate inherits low, high inherits moderate)
            levels = []
            for level in ['low', 'moderate', 'high']:
                if ctrl_id in baselines[level]:
                    levels.append(level)
                    break  # Only record the minimum level

            # Get CIS rules/vars for this control from mapping file
            mapped_rules = nist_to_rules.get(ctrl_id, set())
            mapped_vars = nist_to_vars.get(ctrl_id, set())

            # Filter to only rules/variables that exist in target product
            # For product-specific mode: only include rules present in target product
            # For non-product mode: include all rules (legacy behavior)
            if self.product:
                # Filter rules: only include if in target product's CIS control file
                filtered_rules = [r for r in mapped_rules if r in all_cis_items]

                # Filter variables: only include the specific assignment for target product
                filtered_vars = []
                for var_name in mapped_vars:
                    if var_name in all_cis_items_with_values:
                        # Get all assignments for this variable
                        assignments = all_cis_items_with_values[var_name]
                        # Add all assignments (should only be one per product)
                        filtered_vars.extend(sorted(assignments))

                rules = sorted(filtered_rules)
                vars = filtered_vars
            else:
                # Legacy: include all rules/vars
                rules = sorted(mapped_rules)
                vars = sorted(mapped_vars)

            selections = vars + rules  # Variables first

            # Build control entry (WITHOUT OSCAL metadata - only structure)
            # OSCAL metadata (description, parameters, guidance, related_controls)
            # can be retrieved separately from the OSCAL catalog when needed
            control_entry = {
                'id': ctrl_id,
                'title': ctrl['title']
            }

            if levels:
                control_entry['levels'] = levels

            if selections:
                control_entry['rules'] = selections
                control_entry['status'] = 'automated'
            else:
                control_entry['rules'] = []
                control_entry['status'] = 'pending'

            # Group by family
            family = self.extract_family(ctrl_id)
            controls_by_family[family].append(control_entry)

        # Add unmapped CIS items (items in CIS control files but not in mapping file)
        unmapped_item_names = all_cis_items - mapped_items

        # Build list of unmapped items WITH their values (for variables)
        unmapped_items_full = []
        for item_name in sorted(unmapped_item_names):
            if item_name in all_cis_items_with_values:
                # Get all assignments for this item (may have multiple values across products)
                assignments = all_cis_items_with_values[item_name]
                if len(assignments) == 1:
                    # Single value: use it directly
                    unmapped_items_full.extend(assignments)
                else:
                    # Multiple values: keep them all (guards will be added later)
                    unmapped_items_full.extend(sorted(assignments))
            else:
                # No value found (shouldn't happen, but fallback to name)
                unmapped_items_full.append(item_name)

        if unmapped_items_full:
            controls_by_family['other'].append({
                'id': 'CIS_UNMAPPED',
                'title': 'CIS Benchmark Items Without NIST 800-53 Mapping',
                'notes': LiteralScalarString(
                    'These CIS items do not have explicit NIST 800-53 mappings in the benchmark PDFs.\n'
                    'They are included here to ensure complete CIS coverage when using nist_800_53:all.\n'
                ),
                'rules': unmapped_items_full,
                'status': 'automated'
            })
            print(f"  Added {len(unmapped_item_names)} unmapped CIS items ({len(unmapped_items_full)} total assignments) to 'other' family")

        print(f"  Generated {sum(len(c) for c in controls_by_family.values())} controls across {len(controls_by_family)} families")

        return controls_by_family

    def _dump_yaml(self, data, f):
        """Dump YAML to file, stripping trailing whitespace from each line."""
        buf = io.StringIO()
        self.yaml.dump(data, buf)
        content = buf.getvalue()
        lines = content.splitlines()
        cleaned = '\n'.join(line.rstrip() for line in lines)
        if content.endswith('\n'):
            cleaned += '\n'
        f.write(cleaned)

    def save_split_format(self, controls_by_family: Dict, verbose=False):
        """Save controls in split-by-family format."""
        print(f"\nPhase 6: Saving split format to {self.family_dir}...")

        # Create family directory if needed
        if not self.flat_structure:
            self.family_dir.mkdir(parents=True, exist_ok=True)

        # Write top-level metadata file
        if self.product:
            # Product-specific metadata
            if self.mode == 'reference':
                metadata = {
                    'policy': f'NIST 800-53 Revision 5 CIS Reference ({self.product.upper()})',
                    'title': f'NIST Special Publication 800-53 Revision 5 CIS Reference for {self.product.upper()}',
                    'id': f'nist_800_53_cis_reference_{self.product}',
                    'version': 'Revision 5',
                    'source': 'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final',
                    'product': self.product,
                }
            else:
                metadata = {
                    'policy': f'NIST 800-53 Revision 5 ({self.product.upper()})',
                    'title': f'NIST Special Publication 800-53 Revision 5 for {self.product.upper()}',
                    'id': 'nist_800_53',
                    'version': 'Revision 5',
                    'source': 'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final',
                    'product': self.product,
                }
        else:
            # Legacy non-product-specific metadata (deprecated)
            metadata = {
                'policy': 'NIST 800-53 Revision 5 CIS Reference' if self.mode == 'reference' else 'NIST 800-53 Revision 5',
                'title': 'NIST Special Publication 800-53 Revision 5 CIS Reference' if self.mode == 'reference' else 'NIST Special Publication 800-53 Revision 5',
                'id': 'nist_800_53_cis_reference' if self.mode == 'reference' else 'nist_800_53',
                'version': 'Revision 5',
                'source': 'https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final',
            }

        # Add controls_dir (tells build system where to find family files)
        if self.flat_structure:
            metadata['controls_dir'] = '.'
        else:
            # For subdirectory structure, specify the directory name
            if self.product and self.mode == 'reference':
                dir_name = f'nist_800_53_cis_reference_{self.product}'
            elif self.mode == 'reference':
                dir_name = 'nist_800_53_cis_reference'
            else:
                dir_name = 'nist_800_53'
            metadata['controls_dir'] = dir_name

        # Add levels with inheritance: moderate ⊇ low, high ⊇ moderate
        metadata['levels'] = [
            {'id': 'low'},
            {'id': 'moderate', 'inherits_from': ['low']},
            {'id': 'high', 'inherits_from': ['moderate']}
        ]

        print(f"  Writing top-level file: {self.top_level_file}")
        with open(self.top_level_file, 'w') as f:
            if self.mode == 'reference':
                if self.product:
                    f.write(f"# AUTO-GENERATED Product-Specific CIS Reference File ({self.product.upper()})\n")
                    f.write("#\n")
                    f.write(f"# This file contains only metadata for {self.product.upper()}.\n")
                    f.write(f"# Control families are in nist_800_53_cis_reference_{self.product}/\n")
                    f.write("# Do NOT edit manually. Updated by weekly sync workflow.\n")
                    f.write("#\n")
                    f.write("# OSCAL metadata (description, parameters, guidance, related_controls) is NOT\n")
                    f.write("# included in control files. Retrieve from OSCAL catalog when needed.\n")
                    f.write("#\n")
                elif self.flat_structure:
                    f.write("# AUTO-GENERATED CIS Reference File\n")
                    f.write("#\n")
                    f.write("# This file contains only metadata. Family files are in the same directory.\n")
                    f.write("# Do NOT edit manually. Updated by weekly sync workflow.\n")
                    f.write("#\n")
                else:
                    f.write("# AUTO-GENERATED CIS Reference File\n")
                    f.write("#\n")
                    f.write("# This file contains only metadata. Control families are in nist_800_53_cis_reference/\n")
                    f.write("# Do NOT edit manually. Updated by weekly sync workflow.\n")
                    f.write("#\n")
            self._dump_yaml(metadata, f)

        # Write family files
        for family, controls in sorted(controls_by_family.items()):
            family_file = self.family_dir / f"{self.file_prefix}{family}.yml"
            family_title = self.FAMILIES.get(family, family.upper())

            print(f"  Writing {family.upper()}: {len(controls)} controls → {family_file}")

            with open(family_file, 'w') as f:
                f.write(f"# NIST 800-53 {family.upper()} Family: {family_title}\n")
                self._dump_yaml({'controls': controls}, f)

        print("\n✓ Split format saved!")
        print(f"  Top-level: {self.top_level_file}")
        if self.flat_structure:
            print(f"  Families: {self.family_dir}/{self.file_prefix}*.yml ({len(controls_by_family)} families)")
        else:
            print(f"  Families: {self.family_dir}/*.yml ({len(controls_by_family)} families)")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Generate product-specific NIST 800-53 controls in split format',
        epilog='Example: sync_nist_split.py --product rhel9'
    )
    parser.add_argument('--product', type=str, required=True,
                       help='Target product (rhel8, rhel9, rhel10)')
    parser.add_argument('--mode', type=str, default='reference',
                       choices=['reference', 'real'],
                       help='reference: write to shared/references/ (default); real: write to products/')
    parser.add_argument('--flat', action='store_true',
                       help='Use flat structure (files in same dir with prefix) instead of subdirectory')
    args = parser.parse_args()

    repo_root = Path(__file__).parent.parent.parent

    print("╔════════════════════════════════════════════════════════════╗")
    print("║  NIST 800-53 Product-Specific Synchronization             ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

    print(f"Product: {args.product}")
    print(f"Mode:    {args.mode}")
    print()

    print(f"Generating {args.mode} files for {args.product} (split by family)...")
    syncer = NISTSplitSync(repo_root, product=args.product, mode=args.mode, flat_structure=args.flat)
    controls_by_family = syncer.generate_controls(verbose=False)
    syncer.save_split_format(controls_by_family, verbose=False)

    print()
    print("✓ Synchronization complete!")
    print()
    print("Next steps:")
    if args.mode == 'reference':
        print(f"  1. Review generated files in shared/references/controls/nist_800_53_cis_reference_{args.product}/")
        print(f"  2. Copy to products/{args.product}/controls/nist_800_53/ if needed")
        print("  3. Compare with previous version to detect changes")
    else:
        print(f"  1. Review generated files in products/{args.product}/controls/nist_800_53/")
    print("  4. Test build: ./build_product", args.product, "--datastream-only")

    return 0


if __name__ == '__main__':
    sys.exit(main())
