#!/usr/bin/env python3

"""
Extract Rule-Variable Mappings from OVAL Checks

This script extracts rule-variable mappings from built OVAL content during
the build process. It scans both regular OVAL checks and template-generated
OVAL checks to build a complete mapping of which rules use which variables.

The output is a JSON file that maps rule IDs to lists of variable IDs.

Usage:
    python3 extract_rule_variable_mapping.py <product> <build_dir> <output_file>
"""

import sys
import json
import re
from pathlib import Path
from typing import Dict, Set


def extract_variable_id(var_ref: str) -> str:
    """
    Extract the variable ID from a var_ref attribute value.

    Examples:
        "oval:ssg-var_password_pam_dcredit:var:1" -> "var_password_pam_dcredit"
        "var_password_pam_dcredit" -> "var_password_pam_dcredit"

    Args:
        var_ref: The var_ref attribute value

    Returns:
        The extracted variable ID
    """
    if ':' in var_ref:
        # Format: oval:ssg-var_name:var:1
        parts = var_ref.split(':')
        if len(parts) >= 2:
            var_id = parts[1]
            if var_id.startswith('ssg-'):
                var_id = var_id[4:]  # Remove 'ssg-' prefix
            return var_id
    # Already in simple format
    return var_ref



def extract_internal_variables(content: str) -> Set[str]:
    """
    Extract all internal variable IDs from OVAL content.

    Internal variables include:
    - local_variable: computed/derived variables
    - constant_variable: hardcoded constants (like regex patterns)

    These should be excluded from the external variable dependencies.

    Args:
        content: The OVAL XML content as a string

    Returns:
        Set of internal variable IDs
    """
    internal_vars = set()

    # Pattern: <local_variable id="..." or <oval-def:local_variable id="..."
    local_var_pattern = r'<(?:oval-def:)?local_variable[^>]+id="([^"]+)"'
    matches = re.findall(local_var_pattern, content)
    for var_ref in matches:
        var_id = extract_variable_id(var_ref)
        internal_vars.add(var_id)

    # Pattern: <constant_variable id="..." or <oval-def:constant_variable id="..."
    constant_var_pattern = r'<(?:oval-def:)?constant_variable[^>]+id="([^"]+)"'
    matches = re.findall(constant_var_pattern, content)
    for var_ref in matches:
        var_id = extract_variable_id(var_ref)
        internal_vars.add(var_id)

    return internal_vars


def extract_external_variables(content: str) -> Set[str]:
    """
    Extract all external variable IDs from OVAL content.

    External variables are user-configurable variables that profiles should select.

    Args:
        content: The OVAL XML content as a string

    Returns:
        Set of external variable IDs
    """
    external_vars = set()
    # Pattern: <external_variable id="..." or <oval-def:external_variable id="..."
    external_var_pattern = r'<(?:oval-def:)?external_variable[^>]+id="([^"]+)"'
    matches = re.findall(external_var_pattern, content)

    for var_ref in matches:
        var_id = extract_variable_id(var_ref)
        external_vars.add(var_id)

    return external_vars


def extract_variables_from_oval_content(content: str) -> Set[str]:
    """
    Extract all variable references from OVAL content, excluding internal variables.

    This function finds all var_ref attributes and filters out internal variables
    (local_variable and constant_variable), keeping only external (user-configurable)
    variables.

    Args:
        content: The OVAL XML content as a string

    Returns:
        Set of external variable IDs referenced in the content
    """
    # Find all variable references via var_ref attributes and element text
    var_refs = set()
    var_ref_pattern = r'var_ref="([^"]+)"'
    matches = re.findall(var_ref_pattern, content)

    for var_ref in matches:
        var_id = extract_variable_id(var_ref)
        var_refs.add(var_id)

    # Also capture <ind:var_ref>variable_id</ind:var_ref> element pattern
    var_ref_element_pattern = r'<(?:ind:)?var_ref>([^<]+)</(?:ind:)?var_ref>'
    matches = re.findall(var_ref_element_pattern, content)

    for var_ref in matches:
        var_id = extract_variable_id(var_ref)
        var_refs.add(var_id)

    # Identify internal variables (local + constant)
    internal_vars = extract_internal_variables(content)

    # Identify external variables (user-configurable)
    external_vars = extract_external_variables(content)

    # Only keep variables that are:
    # 1. Either explicitly declared as external variables, OR
    # 2. Referenced but not declared as internal variables
    # This handles cases where external variables might be defined elsewhere
    result = set()
    for var_id in var_refs:
        if var_id in external_vars:
            # Explicitly declared as external
            result.add(var_id)
        elif var_id not in internal_vars:
            # Not declared as internal, assume it's external (defined elsewhere)
            result.add(var_id)
        # else: it's an internal variable (local or constant), skip it

    return result


def process_oval_file(oval_file: Path) -> Dict[str, Set[str]]:
    """
    Process a single OVAL file and extract rule-variable mappings.

    The rule ID is derived from the filename stem — both check formats
    (checks/oval/ with OVAL namespace and checks_from_templates/oval/ with
    bare def-group) name their files after the rule they belong to.

    Args:
        oval_file: Path to the OVAL XML file

    Returns:
        Dictionary mapping the rule ID to the set of variable IDs it depends on
    """
    # The filename stem is the rule ID for both OVAL file formats.  Using the
    # filename avoids the need to parse definition IDs, which differ between
    # checks/oval/ (oval:ssg-<id>:def:1 with oval-def: namespace prefix) and
    # checks_from_templates/oval/ (bare <definition id="<id>">) formats.
    rule_id = oval_file.stem

    try:
        with open(oval_file, 'r', encoding='utf-8') as f:
            content = f.read()

        var_refs = extract_variables_from_oval_content(content)
        if var_refs:
            return {rule_id: var_refs}

    except (IOError, UnicodeDecodeError) as e:
        print(f"Warning: Could not process {oval_file}: {e}", file=sys.stderr)

    return {}


def build_rule_variable_mapping(product: str, build_dir: Path) -> Dict[str, list]:
    """
    Build complete rule-variable mapping for a product.

    Args:
        product: Product name (e.g., 'rhel10')
        build_dir: Path to the build directory

    Returns:
        Dictionary mapping rule IDs to lists of variable IDs
    """
    product_dir = build_dir / product
    checks_dir = product_dir / "checks" / "oval"
    templates_dir = product_dir / "checks_from_templates" / "oval"

    # Aggregate all rule-variable mappings
    all_mappings: Dict[str, Set[str]] = {}

    # Process regular OVAL checks
    if checks_dir.exists():
        for oval_file in checks_dir.glob("*.xml"):
            rule_vars = process_oval_file(oval_file)
            for rule_id, var_ids in rule_vars.items():
                if rule_id not in all_mappings:
                    all_mappings[rule_id] = set()
                all_mappings[rule_id].update(var_ids)

    # Process template-generated OVAL checks
    if templates_dir.exists():
        for oval_file in templates_dir.glob("*.xml"):
            rule_vars = process_oval_file(oval_file)
            for rule_id, var_ids in rule_vars.items():
                if rule_id not in all_mappings:
                    all_mappings[rule_id] = set()
                all_mappings[rule_id].update(var_ids)

    # Convert sets to sorted lists for JSON serialization
    result = {rule_id: sorted(list(var_ids)) for rule_id, var_ids in all_mappings.items()}

    return result


def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <product> <build_dir> <output_file>", file=sys.stderr)
        print(f"Example: {sys.argv[0]} rhel10 build build/rhel10/rule_variable_mapping.json", file=sys.stderr)
        return 1

    product = sys.argv[1]
    build_dir = Path(sys.argv[2])
    output_file = Path(sys.argv[3])

    if not build_dir.exists():
        print(f"Error: Build directory {build_dir} does not exist", file=sys.stderr)
        return 1

    # Build the mapping
    mapping = build_rule_variable_mapping(product, build_dir)

    # Ensure output directory exists
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # Write to JSON file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(mapping, f, indent=2, sort_keys=True)

    # Always return 0 so build failures in individual OVAL files (logged as
    # warnings) don't break the overall build. Enforcement can be added later.
    return 0


if __name__ == '__main__':
    sys.exit(main())
