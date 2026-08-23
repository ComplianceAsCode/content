#!/usr/bin/env python3
"""
Harvest NIST 800-53 mappings from CIS benchmark documents and control files.

This script:
1. Parses CIS benchmark MD and PDF files to extract NIST references for each CIS control
2. Reads CIS control YAML files to get rule mappings for each CIS control
3. Combines them to create rule → NIST control mappings
4. Updates the nist_800_53.yml control file with these mappings
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set
from collections import defaultdict

try:
    from ruamel.yaml import YAML
except ImportError:
    print("Error: ruamel.yaml is required. Install it with:", file=sys.stderr)
    print("  pip install ruamel.yaml", file=sys.stderr)
    sys.exit(1)

try:
    import PyPDF2
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False
    print("Warning: PyPDF2 not available. PDF parsing will be skipped.", file=sys.stderr)
    print("  Install with: pip install PyPDF2", file=sys.stderr)


class CISNISTHarvester:
    """Harvests NIST mappings from CIS benchmarks and control files."""

    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.nist_sync_dir = repo_root / "utils" / "nist_sync"
        self.nist_control_file = repo_root / "controls" / "nist_800_53.yml"
        self.mapping_cache_file = self.nist_sync_dir / "data" / "cis_nist_mappings.json"

        # Setup YAML parser
        self.yaml = YAML()
        self.yaml.preserve_quotes = True
        self.yaml.default_flow_style = False
        self.yaml.indent(mapping=2, sequence=4, offset=2)
        self.yaml.width = 4096

    def parse_cis_md_file(self, md_file: Path) -> Dict[str, Set[str]]:
        """
        Parse CIS benchmark MD file to extract NIST references.

        Args:
            md_file: Path to CIS benchmark MD file

        Returns:
            Dict mapping CIS control ID to set of NIST control IDs
            e.g., {"1.1.1.1": {"cm-7"}, "1.2.1": {"ac-2", "ac-3"}}
        """
        print(f"  Parsing {md_file.name}...")

        with open(md_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        cis_to_nist = {}
        current_cis_id = None

        for line in lines:
            # Check if this is a CIS control header
            # Pattern: # *1.1.1.1 Ensure ...*
            cis_header = re.match(r'^#+ \*([0-9.]+)\s+[^*]+\*', line)
            if cis_header:
                current_cis_id = cis_header.group(1)
                continue

            # Check if line contains NIST reference
            # Pattern matches multiple formats:
            # - "NIST SP 800-53 Rev. 5: CM-7"
            # - "NIST SP 800-53 :: CM-7"
            # - "NIST SP 800-53: CM-7 a"
            nist_match = re.search(
                r'NIST SP 800-53(?:\s+Rev\.?\s*\d+)?(?:\s*[:]{1,2})\s*([A-Z]{2}-[0-9]+(?:\([0-9]+\))?)(?:\s+[a-z])?',
                line
            )

            if nist_match and current_cis_id:
                ctrl = nist_match.group(1)
                # Convert to OSCAL format
                ctrl = ctrl.lower()  # Lowercase
                ctrl = re.sub(r'\((\d+)\)', r'.\1', ctrl)  # ac-2(5) → ac-2.5

                if current_cis_id not in cis_to_nist:
                    cis_to_nist[current_cis_id] = set()
                cis_to_nist[current_cis_id].add(ctrl)

        print(f"    Found {len(cis_to_nist)} CIS controls with NIST references")
        return cis_to_nist

    def parse_cis_pdf_file(self, pdf_file: Path) -> Dict[str, Set[str]]:
        """
        Parse CIS benchmark PDF file to extract NIST references using pdftotext.

        Args:
            pdf_file: Path to CIS benchmark PDF file

        Returns:
            Dict mapping CIS control ID to set of NIST control IDs
        """
        import subprocess
        import shutil

        # Check if pdftotext is available
        if not shutil.which('pdftotext'):
            print("  Skipping PDF parsing (pdftotext not available)")
            return {}

        print(f"  Parsing {pdf_file.name}...")

        try:
            # Use pdftotext to extract text
            result = subprocess.run(
                ['pdftotext', '-layout', str(pdf_file), '-'],
                capture_output=True,
                text=True,
                timeout=60
            )

            if result.returncode != 0:
                print(f"    Warning: pdftotext failed with code {result.returncode}")
                return {}

            text = result.stdout
            cis_to_nist = {}
            current_cis_id = None

            # Process line by line
            for line in text.split('\n'):
                # Check for CIS control header
                # Patterns: "1.1.1.1 Ensure..." or variations
                cis_header = re.search(r'\b([0-9]+\.[0-9.]+)\s+Ensure', line)
                if cis_header:
                    current_cis_id = cis_header.group(1)
                    continue

                # Check for NIST reference
                nist_match = re.search(
                    r'NIST SP 800-53(?:\s+Rev\.?\s*\d+)?(?:\s*[:]{1,2})\s*([A-Z]{2}-[0-9]+(?:\([0-9]+\))?)(?:\s+[a-z])?',
                    line
                )

                if nist_match and current_cis_id:
                    ctrl = nist_match.group(1)
                    # Convert to OSCAL format
                    ctrl = ctrl.lower()
                    ctrl = re.sub(r'\((\d+)\)', r'.\1', ctrl)

                    if current_cis_id not in cis_to_nist:
                        cis_to_nist[current_cis_id] = set()
                    cis_to_nist[current_cis_id].add(ctrl)

            print(f"    Found {len(cis_to_nist)} CIS controls with NIST references")
            return cis_to_nist

        except subprocess.TimeoutExpired:
            print("    Warning: PDF parsing timed out")
            return {}
        except Exception as e:
            print(f"    Warning: Failed to parse PDF: {e}")
            return {}

    def merge_nist_mappings(
        self,
        md_mapping: Dict[str, Set[str]],
        pdf_mapping: Dict[str, Set[str]]
    ) -> Dict[str, Set[str]]:
        """
        Merge NIST mappings from MD and PDF sources.

        Args:
            md_mapping: CIS→NIST from MD file
            pdf_mapping: CIS→NIST from PDF file

        Returns:
            Merged mapping with all unique NIST controls per CIS control
        """
        merged = defaultdict(set)

        # Add MD mappings
        for cis_id, nist_controls in md_mapping.items():
            merged[cis_id].update(nist_controls)

        # Add PDF mappings
        for cis_id, nist_controls in pdf_mapping.items():
            merged[cis_id].update(nist_controls)

        return dict(merged)

    def parse_cis_control_file(self, control_file: Path) -> Dict[str, List[str]]:
        """
        Parse CIS control YAML file to extract rule mappings.

        Args:
            control_file: Path to CIS control YAML file

        Returns:
            Dict mapping CIS control ID to list of rules
            e.g., {"1.1.1.1": ["kernel_module_cramfs_disabled"]}
        """
        print(f"  Parsing {control_file.name}...")

        with open(control_file, 'r', encoding='utf-8') as f:
            control_data = self.yaml.load(f)

        cis_to_rules = {}

        for control in control_data.get('controls', []):
            cis_id = control.get('id')
            rules = control.get('rules', [])

            if cis_id and rules:
                # Filter out variable assignments (contain '=')
                rule_ids = [r for r in rules if '=' not in r]
                if rule_ids:
                    cis_to_rules[cis_id] = rule_ids

        print(f"    Found {len(cis_to_rules)} CIS controls with rules")
        return cis_to_rules

    def parse_cis_control_file_variables(self, control_file: Path) -> Dict[str, List[str]]:
        """
        Parse CIS control YAML file to extract variable assignments.

        Args:
            control_file: Path to CIS control YAML file

        Returns:
            Dict mapping CIS control ID to list of variable assignments
            e.g., {"enable_authselect": ["var_authselect_profile=sssd"]}
        """
        print(f"  Parsing variables from {control_file.name}...")

        with open(control_file, 'r', encoding='utf-8') as f:
            control_data = self.yaml.load(f)

        cis_to_vars = {}

        for control in control_data.get('controls', []):
            cis_id = control.get('id')
            rules = control.get('rules', [])

            if cis_id and rules:
                # Extract only variable assignments (contain '=')
                var_assignments = [r for r in rules if '=' in r]
                if var_assignments:
                    cis_to_vars[cis_id] = var_assignments

        print(f"    Found {len(cis_to_vars)} CIS controls with variables")
        return cis_to_vars

    def build_rule_to_nist_mapping(
        self,
        cis_to_nist: Dict[str, Set[str]],
        cis_to_rules: Dict[str, List[str]]
    ) -> Dict[str, Set[str]]:
        """
        Combine CIS→NIST and CIS→rules mappings to create rule→NIST mapping.

        Args:
            cis_to_nist: CIS control ID → NIST control IDs
            cis_to_rules: CIS control ID → rule IDs

        Returns:
            Dict mapping rule ID to set of NIST control IDs
        """
        rule_to_nist = defaultdict(set)

        for cis_id, nist_controls in cis_to_nist.items():
            if cis_id in cis_to_rules:
                rules = cis_to_rules[cis_id]
                for rule_id in rules:
                    rule_to_nist[rule_id].update(nist_controls)

        return dict(rule_to_nist)

    def build_variable_to_nist_mapping(
        self,
        cis_to_nist: Dict[str, Set[str]],
        cis_to_vars: Dict[str, List[str]]
    ) -> Dict[str, Set[str]]:
        """
        Combine CIS→NIST and CIS→variables mappings to create variable→NIST mapping.

        Args:
            cis_to_nist: CIS control ID → NIST control IDs
            cis_to_vars: CIS control ID → variable assignments

        Returns:
            Dict mapping variable assignment to set of NIST control IDs
        """
        var_to_nist = defaultdict(set)

        for cis_id, nist_controls in cis_to_nist.items():
            if cis_id in cis_to_vars:
                variables = cis_to_vars[cis_id]
                for var_assignment in variables:
                    var_to_nist[var_assignment].update(nist_controls)

        return dict(var_to_nist)

    def harvest_from_product(
        self,
        product: str,
        rhel_version: str
    ) -> tuple[Dict[str, Set[str]], Dict[str, Set[str]]]:
        """
        Harvest NIST mappings for a specific product.

        Args:
            product: Product ID (e.g., "rhel9")
            rhel_version: RHEL version for file matching (e.g., "9")

        Returns:
            Tuple of (rule_to_nist, var_to_nist) mappings
        """
        print(f"\nHarvesting from {product}...")

        # Find CIS PDF file
        pdf_pattern = f"CIS_Red_Hat_Enterprise_Linux_{rhel_version}_Benchmark_*.pdf"
        pdf_files = list(self.nist_sync_dir.glob(pdf_pattern))

        # Find CIS control file
        control_file = self.repo_root / "products" / product / "controls" / f"cis_{product}.yml"

        if not control_file.exists():
            print(f"  Warning: CIS control file not found at {control_file}")
            return {}, {}

        # Parse MD file if available
        # NOTE: MD files have formatting issues - skip MD parsing and use PDF only
        # if md_files:
        #     md_mapping = self.parse_cis_md_file(md_files[0])
        # else:
        #     print(f"  Warning: No CIS MD file found matching {md_pattern}")
        print("  Skipping MD parsing (using PDF only for more reliable NIST reference extraction)")

        # Parse PDF file if available
        pdf_mapping = {}
        if pdf_files:
            pdf_mapping = self.parse_cis_pdf_file(pdf_files[0])
        else:
            print(f"  Warning: No CIS PDF file found matching {pdf_pattern}")

        # Use PDF mappings only
        print("  Using PDF mappings...")
        cis_to_nist = pdf_mapping
        print(f"    ✓ Total: {len(cis_to_nist)} CIS controls with NIST references")

        # Parse control file to get CIS→rules mapping
        cis_to_rules = self.parse_cis_control_file(control_file)

        # Parse control file to get CIS→variables mapping
        cis_to_vars = self.parse_cis_control_file_variables(control_file)

        # Combine to get rule→NIST mapping
        rule_to_nist = self.build_rule_to_nist_mapping(cis_to_nist, cis_to_rules)

        # Combine to get variable→NIST mapping
        var_to_nist = self.build_variable_to_nist_mapping(cis_to_nist, cis_to_vars)

        print(f"  ✓ Mapped {len(rule_to_nist)} rules to NIST controls")
        print(f"  ✓ Mapped {len(var_to_nist)} variables to NIST controls")

        return rule_to_nist, var_to_nist

    def merge_rule_mappings(
        self,
        *mappings: Dict[str, Set[str]]
    ) -> Dict[str, Set[str]]:
        """
        Merge multiple rule→NIST mappings.

        Args:
            *mappings: Variable number of rule→NIST mapping dicts

        Returns:
            Combined dict with all unique mappings
        """
        merged = defaultdict(set)

        for mapping in mappings:
            for rule_id, nist_controls in mapping.items():
                merged[rule_id].update(nist_controls)

        return dict(merged)

    def save_mapping_cache(
        self,
        rule_to_nist: Dict[str, Set[str]],
        var_to_nist: Dict[str, Set[str]]
    ):
        """Save rule→NIST and variable→NIST mappings to JSON cache file."""
        import json

        # Convert sets to lists for JSON serialization
        cache_data = {
            'rules': {
                rule_id: sorted(list(nist_controls))
                for rule_id, nist_controls in rule_to_nist.items()
            },
            'variables': {
                var_id: sorted(list(nist_controls))
                for var_id, nist_controls in var_to_nist.items()
            }
        }

        self.mapping_cache_file.parent.mkdir(parents=True, exist_ok=True)

        with open(self.mapping_cache_file, 'w', encoding='utf-8') as f:
            json.dump(cache_data, f, indent=2, sort_keys=True)

        print(f"\n✓ Saved mapping cache to {self.mapping_cache_file}")
        print(f"  {len(cache_data['rules'])} rules mapped to NIST controls")
        print(f"  {len(cache_data['variables'])} variables mapped to NIST controls")

    @staticmethod
    def load_mapping_cache(cache_file: Path) -> Dict[str, Set[str]]:
        """Load rule→NIST mapping from JSON cache file."""
        import json

        if not cache_file.exists():
            return {}

        with open(cache_file, 'r', encoding='utf-8') as f:
            cache_data = json.load(f)

        # Convert lists back to sets
        return {
            rule_id: set(nist_controls)
            for rule_id, nist_controls in cache_data.items()
        }

    def update_nist_control_file(
        self,
        rule_to_nist: Dict[str, Set[str]],
        dry_run: bool = False
    ):
        """
        Update nist_800_53.yml control file with rule mappings.

        Args:
            rule_to_nist: Dict mapping rule ID to set of NIST control IDs
            dry_run: If True, show changes without saving
        """
        print("\nUpdating NIST control file...")

        # Load control file
        with open(self.nist_control_file, 'r', encoding='utf-8') as f:
            control_data = self.yaml.load(f)

        # Create lookup of controls by ID
        controls_by_id = {
            ctrl['id']: ctrl
            for ctrl in control_data.get('controls', [])
        }

        # Build reverse mapping: NIST control ID → rules
        nist_to_rules = defaultdict(set)
        for rule_id, nist_controls in rule_to_nist.items():
            for nist_id in nist_controls:
                nist_to_rules[nist_id].add(rule_id)

        # Update controls
        rules_added = 0
        controls_updated = 0
        controls_not_found = []

        for nist_id, rules in sorted(nist_to_rules.items()):
            if nist_id in controls_by_id:
                control = controls_by_id[nist_id]
                existing_rules = set(control.get('rules', []))

                # Filter out variable assignments from existing rules
                existing_rules = {r for r in existing_rules if '=' not in r}

                # Add new rules
                new_rules = rules - existing_rules
                if new_rules:
                    if 'rules' not in control:
                        control['rules'] = []

                    # Add new rules (sorted)
                    control['rules'].extend(sorted(new_rules))
                    # Re-sort all rules
                    control['rules'] = sorted(set(r for r in control['rules'] if '=' not in r))

                    # Update status to automated if rules are present
                    if control.get('status') == 'pending' and control['rules']:
                        control['status'] = 'automated'

                    rules_added += len(new_rules)
                    controls_updated += 1

                    if dry_run:
                        print(f"  {nist_id}: would add {len(new_rules)} rules")
            else:
                controls_not_found.append(nist_id)

        print(f"  ✓ Updated {controls_updated} controls")
        print(f"  ✓ Added {rules_added} rule mappings")

        if controls_not_found:
            print(f"  ! {len(controls_not_found)} NIST controls not found in control file:")
            for nist_id in sorted(controls_not_found)[:10]:
                print(f"      {nist_id}")
            if len(controls_not_found) > 10:
                print(f"      ... and {len(controls_not_found) - 10} more")

        if not dry_run:
            # Save control file
            print(f"  Saving to {self.nist_control_file}...")
            with open(self.nist_control_file, 'w', encoding='utf-8') as f:
                self.yaml.dump(control_data, f)
            print("  ✓ Saved")
        else:
            print("  (Dry run - no changes saved)")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Harvest NIST mappings from CIS benchmarks'
    )
    parser.add_argument(
        '--products',
        nargs='+',
        default=['rhel8', 'rhel9', 'rhel10'],
        help='Products to harvest from (default: rhel8 rhel9 rhel10)'
    )
    parser.add_argument(
        '--repo-root',
        type=Path,
        default=Path(__file__).parent.parent.parent,
        help='Path to repository root (default: auto-detect)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be changed without saving'
    )

    args = parser.parse_args()

    harvester = CISNISTHarvester(args.repo_root)

    # Product to RHEL version mapping
    product_to_version = {
        'rhel8': '8',
        'rhel9': '9',
        'rhel10': '10'
    }

    print("╔════════════════════════════════════════════════════════════╗")
    print("║   CIS NIST Mapping Harvester                               ║")
    print("╚════════════════════════════════════════════════════════════╝")

    try:
        # Harvest from each product
        all_rule_mappings = []
        all_var_mappings = []
        for product in args.products:
            if product not in product_to_version:
                print(f"Warning: Unknown product {product}, skipping")
                continue

            rhel_version = product_to_version[product]
            rule_mapping, var_mapping = harvester.harvest_from_product(product, rhel_version)
            all_rule_mappings.append(rule_mapping)
            all_var_mappings.append(var_mapping)

        # Merge all mappings
        print("\nMerging mappings from all products...")
        merged_rules = harvester.merge_rule_mappings(*all_rule_mappings)
        merged_vars = harvester.merge_rule_mappings(*all_var_mappings)  # Same merge logic
        print(f"  ✓ Total unique rules: {len(merged_rules)}")
        print(f"  ✓ Total unique variables: {len(merged_vars)}")

        # Save mapping cache (always save, even in dry-run)
        harvester.save_mapping_cache(merged_rules, merged_vars)

        # Note: update_nist_control_file is not used in the new workflow
        # The sync_nist.py script handles updating the control file

        print("\n✓ Harvest complete!")
        print(f"\nMapping cache saved to: {harvester.mapping_cache_file}")
        print("This cache can be used by sync_nist.py to populate rule and variable mappings.")
        return 0

    except Exception as e:
        print(f"\n✗ Harvest failed: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
