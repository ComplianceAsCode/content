#!/usr/bin/python3

"""
Build CEL content YAML file for compliance scanning.

This module generates a CEL content file containing rules that use
the Common Expression Language (CEL) scanner instead of OVAL checks.
"""

import argparse
import logging
import os
import sys
import yaml

import ssg.build_yaml
import ssg.products
import ssg.utils

MESSAGE_FORMAT = "%(levelname)s: %(message)s"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generates CEL content YAML file from resolved rules"
    )
    parser.add_argument(
        "--resolved-rules-dir", required=True,
        help="Directory containing resolved rule json files. "
        "e.g.: ~/scap-security-guide/build/rhel9/rules"
    )
    parser.add_argument(
        "--profiles-dir", required=True,
        help="Directory containing resolved profile YAML files. "
        "e.g.: ~/scap-security-guide/build/ocp4/profiles"
    )
    parser.add_argument(
        "--product-yaml", required=True,
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/build/ocp4/product.yml"
    )
    parser.add_argument(
        "--output", required=True,
        help="Output CEL content YAML file. "
        "e.g.: ~/scap-security-guide/build/ocp4/ssg-ocp4-cel-content.yaml"
    )
    parser.add_argument(
        "--log",
        action="store",
        default="WARNING",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="write debug information to the log up to the LOG_LEVEL.",
    )
    return parser.parse_args()


def setup_logging(log_level_str):
    numeric_level = getattr(logging, log_level_str.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError("Invalid log level: {}".format(log_level_str))
    logging.basicConfig(format=MESSAGE_FORMAT, level=numeric_level)


def load_cel_rules(rules_dir):
    """
    Load all rules that use the CEL checking engine.

    Args:
        rules_dir: Directory containing resolved rule JSON files

    Returns:
        dict: Dictionary of rule_id -> rule object for rules with CEL checks

    Raises:
        ValueError: If a rule with CEL checks is missing required fields
    """
    cel_rules = {}

    if not os.path.isdir(rules_dir):
        return cel_rules

    for rule_file in os.listdir(rules_dir):
        rule_path = os.path.join(rules_dir, rule_file)
        try:
            rule = ssg.build_yaml.Rule.from_compiled_json(rule_path)

            # Check if this rule has CEL checks by looking for CEL-specific fields
            # A rule uses CEL if it has both expression and inputs
            # (loaded from cel/shared.yml during rule compilation)
            has_expression = hasattr(rule, 'expression') and rule.expression
            has_inputs = hasattr(rule, 'inputs') and rule.inputs

            if has_expression and has_inputs:
                # Validate required CEL fields
                rule_name = rule_id_to_name(rule.id_)

                if not hasattr(rule, 'check_type') or not rule.check_type:
                    logging.warning(
                        f"Rule '{rule_name}' with CEL checks in {rule_file} has no check_type, defaulting to 'Platform'"
                    )
                    rule.check_type = 'Platform'

                cel_rules[rule.id_] = rule
        except ssg.build_yaml.DocumentationNotComplete:
            # Skip documentation-incomplete rules in non-debug builds
            continue
        except ValueError:
            # Re-raise validation errors
            raise
        except Exception as e:
            logging.warning("Failed to load rule from %s: %s", rule_file, e)
            continue

    return cel_rules


def load_profiles(profiles_dir, cel_rule_ids):
    """
    Load profiles that target the CEL checking engine (scanner_type: CEL).

    Args:
        profiles_dir: Directory containing profile YAML files
        cel_rule_ids: Set of rule IDs that have CEL checks

    Returns:
        list: List of profile objects targeting CEL

    Raises:
        ValueError: If a profile targeting CEL is missing required fields
    """
    profiles = []

    if not os.path.isdir(profiles_dir):
        return profiles

    for profile_file in os.listdir(profiles_dir):
        profile_path = os.path.join(profiles_dir, profile_file)
        try:
            profile = ssg.build_yaml.Profile.from_compiled_json(profile_path)

            # Only load profiles targeting the CEL checking engine
            if hasattr(profile, 'scanner_type') and profile.scanner_type == 'CEL':
                # Validate required profile fields
                profile_name = rule_id_to_name(profile.id_)

                if not hasattr(profile, 'selected') or not profile.selected:
                    raise ValueError(
                        f"Profile '{profile_name}' targeting CEL in {profile_file} has no rules"
                    )

                profiles.append(profile)
        except ValueError:
            # Re-raise validation errors
            raise
        except Exception as e:
            logging.warning("Failed to load profile from %s: %s", profile_file, e)
            continue

    return profiles


def rule_id_to_name(rule_id):
    """Convert rule_id with underscores to name with hyphens."""
    return rule_id.replace('_', '-')


def extract_controls_from_references(references):
    """
    Extract controls from references dict, keeping original keys.

    Args:
        references: Dictionary of references like {"cis@ocp4": ["1.2.3"], "nist": ["AC-6"]}

    Returns:
        dict: Controls dictionary grouped by framework
    """
    if not references:
        return {}

    controls = {}
    for ref_key, ref_values in references.items():
        # Keep the original key format (e.g., "cis@ocp4", "nist")
        if isinstance(ref_values, list):
            controls[ref_key] = ref_values
        elif isinstance(ref_values, str):
            controls[ref_key] = [ref_values]

    return controls


def convert_inputs_to_camelcase(inputs):
    """
    Convert kubernetes_input_spec fields from snake_case to camelCase for CRD compatibility.

    Args:
        inputs: List of input dictionaries

    Returns:
        list: Inputs with camelCase field names
    """
    if not inputs:
        return inputs

    converted_inputs = []
    for input_item in inputs:
        converted_item = dict(input_item)
        if 'kubernetes_input_spec' in converted_item:
            spec = converted_item['kubernetes_input_spec']
            camel_spec = {}

            # Convert snake_case keys to camelCase
            key_mapping = {
                'api_version': 'apiVersion',
                'resource_name': 'resourceName',
                'resource_namespace': 'resourceNamespace',
            }

            for key, value in spec.items():
                camel_key = key_mapping.get(key, key)
                camel_spec[camel_key] = value

            converted_item['kubernetesInputSpec'] = camel_spec
            del converted_item['kubernetes_input_spec']

        converted_inputs.append(converted_item)

    return converted_inputs


def rule_to_cel_dict(rule):
    """
    Convert a Rule object to CEL content dictionary format.

    Args:
        rule: Rule object

    Returns:
        dict: Rule in CEL content format
    """
    cel_rule = {
        'id': rule.id_,  # Keep underscores for id
        'name': rule_id_to_name(rule.id_),  # Convert to hyphens for name
        'title': rule.title,
        'description': rule.description,
        'rationale': rule.rationale,
        'severity': rule.severity,
        'checkType': rule.check_type if hasattr(rule, 'check_type') and rule.check_type else 'Platform',
    }

    # Add instructions from ocil field
    if hasattr(rule, 'ocil') and rule.ocil:
        cel_rule['instructions'] = rule.ocil

    # Add failureReason if present
    if hasattr(rule, 'failure_reason') and rule.failure_reason:
        cel_rule['failureReason'] = rule.failure_reason

    # Add CEL expression
    if hasattr(rule, 'expression') and rule.expression:
        cel_rule['expression'] = rule.expression

    # Add inputs (convert to camelCase for CRD compatibility)
    if hasattr(rule, 'inputs') and rule.inputs:
        cel_rule['inputs'] = convert_inputs_to_camelcase(rule.inputs)

    # Add controls from references
    controls = extract_controls_from_references(rule.references)
    if controls:
        cel_rule['controls'] = controls

    return cel_rule


def profile_to_cel_dict(profile, cel_rule_ids):
    """
    Convert a Profile object to CEL content dictionary format.

    Args:
        profile: Profile object
        cel_rule_ids: Set of rule IDs that have CEL checks

    Returns:
        dict: Profile in CEL content format
    """
    # Filter selected rules to only include rules with CEL checks
    profile_cel_rules = [rule_id_to_name(rid) for rid in profile.selected if rid in cel_rule_ids]

    if not profile_cel_rules:
        return None

    cel_profile = {
        'id': profile.id_,
        'name': rule_id_to_name(profile.id_),
        'title': profile.title,
        'description': profile.description,
        'productType': 'Platform',  # Default for OCP4
        'rules': sorted(profile_cel_rules)
    }

    return cel_profile


def generate_cel_content(cel_rules, profiles):
    """
    Generate the complete CEL content structure.

    Args:
        cel_rules: Dictionary of rules with CEL checks
        profiles: List of profiles targeting the CEL checking engine

    Returns:
        dict: Complete CEL content structure

    Raises:
        ValueError: If duplicate rule names found or profile references unknown rules
    """
    cel_rule_ids = set(cel_rules.keys())

    # Generate rules section and check for duplicates
    cel_rules_list = []
    rule_names_seen = set()
    for rule_id in sorted(cel_rules.keys()):
        rule = cel_rules[rule_id]
        cel_rule = rule_to_cel_dict(rule)

        # Check for duplicate rule names
        rule_name = cel_rule['name']
        if rule_name in rule_names_seen:
            raise ValueError(f"duplicate rule name: {rule_name}")
        rule_names_seen.add(rule_name)

        cel_rules_list.append(cel_rule)

    # Generate profiles section and validate rule references
    cel_profiles = []
    for profile in profiles:
        # Validate that all selected rules have CEL checks
        profile_name = rule_id_to_name(profile.id_)
        for rule_id in profile.selected:
            if rule_id not in cel_rule_ids:
                rule_name = rule_id_to_name(rule_id)
                raise ValueError(
                    f"profile '{profile_name}' references unknown rule '{rule_name}'"
                )

        cel_profile = profile_to_cel_dict(profile, cel_rule_ids)
        if cel_profile:
            cel_profiles.append(cel_profile)

    # Build the complete structure
    content = {
        'profiles': cel_profiles,
        'rules': cel_rules_list
    }

    return content


def main():
    args = parse_args()
    setup_logging(args.log)

    # Load rules with CEL checks
    cel_rules = load_cel_rules(args.resolved_rules_dir)

    if not cel_rules:
        content = {'profiles': [], 'rules': []}
    else:
        # Load profiles
        profiles = load_profiles(args.profiles_dir, set(cel_rules.keys()))

        # Generate CEL content
        content = generate_cel_content(cel_rules, profiles)

    # Write output YAML
    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    with open(args.output, 'w') as f:
        yaml.dump(content, f, default_flow_style=False, sort_keys=False, allow_unicode=True)


if __name__ == "__main__":
    main()
