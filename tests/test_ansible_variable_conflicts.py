#!/usr/bin/python3

"""
Test that ansible registered variables don't conflict with rule IDs.

This test checks the rendered ansible remediation files (after template
expansion) to ensure that no registered variable names match rule IDs.
Such conflicts can cause issues where the registered variable name shadows
the rule ID control variable that determines if the rule should be applied.

For example, if we have a rule 'selinux_state', the ansible remediation
should not register a variable also called 'selinux_state', as this
conflicts with the control variable typically used in conditions like
'when: selinux_state | bool'.
"""

import argparse
import os
import sys
import yaml


def get_all_rule_ids(build_dir):
    """
    Extract all rule IDs from the rules directories in the build directory.

    Args:
        build_dir: The build directory containing compiled product data

    Returns:
        set: A set of all rule IDs found across all products
    """
    rule_ids = set()

    # Look for rules directories in each product build
    for product_dir in os.listdir(build_dir):
        rules_dir = os.path.join(build_dir, product_dir, "rules")
        if not os.path.isdir(rules_dir):
            continue

        # Each .json file in rules/ represents a rule
        for filename in os.listdir(rules_dir):
            if filename.endswith('.json'):
                rule_id = os.path.splitext(filename)[0]
                rule_ids.add(rule_id)

    return rule_ids


def extract_registered_variables(tasks):
    """
    Recursively extract all registered variable names from ansible tasks.

    Args:
        tasks: A list of ansible tasks or a single task dict

    Returns:
        set: A set of all registered variable names found
    """
    registered_vars = set()

    if not tasks:
        return registered_vars

    # Handle both list of tasks and single task
    if isinstance(tasks, dict):
        tasks = [tasks]

    if not isinstance(tasks, list):
        return registered_vars

    for task in tasks:
        if not isinstance(task, dict):
            continue

        # Check if task has a 'register' key
        if 'register' in task:
            var_name = task['register']
            if isinstance(var_name, str):
                registered_vars.add(var_name)

        # Recursively check blocks
        if 'block' in task and isinstance(task['block'], list):
            registered_vars.update(extract_registered_variables(task['block']))

        # Recursively check rescue blocks
        if 'rescue' in task and isinstance(task['rescue'], list):
            registered_vars.update(extract_registered_variables(task['rescue']))

        # Recursively check always blocks
        if 'always' in task and isinstance(task['always'], list):
            registered_vars.update(extract_registered_variables(task['always']))

    return registered_vars


def check_ansible_file(ansible_file, rule_ids, product):
    """
    Check a single ansible file for variable conflicts.

    Args:
        ansible_file: Path to the ansible file to check
        rule_ids: Set of all rule IDs to check against
        product: The product ID

    Returns:
        list: A list of dicts describing conflicts found in this file
    """
    conflicts = []

    try:
        with open(ansible_file, 'r') as f:
            content = f.read()

            # Skip files that still have unexpanded Jinja or XCCDF variables
            if '(xccdf-var' in content or '{{{' in content:
                return conflicts

            try:
                # Handle both single playbook format and task list format
                data = yaml.safe_load(content)
                if not data:
                    return conflicts

                # Extract tasks from playbook format or direct task list
                tasks = []
                if isinstance(data, list):
                    # Could be a list of plays or a list of tasks
                    if data and isinstance(data[0], dict):
                        if 'hosts' in data[0]:
                            # It's a playbook with plays
                            for play in data:
                                if 'tasks' in play:
                                    tasks.extend(play['tasks'])
                                if 'pre_tasks' in play:
                                    tasks.extend(play['pre_tasks'])
                                if 'post_tasks' in play:
                                    tasks.extend(play['post_tasks'])
                        else:
                            # It's a direct list of tasks
                            tasks = data

                # Extract registered variable names
                registered_vars = extract_registered_variables(tasks)

                # Check if any registered variable matches a rule ID
                for var_name in registered_vars:
                    if var_name in rule_ids:
                        conflicts.append({
                            'file': ansible_file,
                            'variable': var_name,
                            'conflicting_rule': var_name,
                            'product': product
                        })
            except yaml.YAMLError as e:
                # Skip files that can't be parsed
                print(f"Warning: Could not parse {ansible_file}: {e}", file=sys.stderr)
                return conflicts
    except IOError as e:
        # Skip files that can't be read
        print(f"Warning: Could not read {ansible_file}: {e}", file=sys.stderr)
        return conflicts

    return conflicts


def check_ansible_files_for_conflicts(build_dir, product, rule_ids):
    """
    Check all rendered ansible files for a product for variable conflicts.

    This checks both:
    1. Individual rule fixes in build/<product>/fixes/ansible/
    2. Per-profile playbooks in build/ansible/<product>-playbook-*.yml

    Args:
        build_dir: The build directory
        product: The product ID to check
        rule_ids: Set of all rule IDs to check against

    Returns:
        list: A list of dicts describing conflicts found
    """
    conflicts = []

    # Check the ansible fixes directory (individual rule remediations)
    ansible_fixes_dir = os.path.join(build_dir, product, "fixes", "ansible")
    if os.path.exists(ansible_fixes_dir):
        for filename in os.listdir(ansible_fixes_dir):
            if not filename.endswith(".yml"):
                continue

            ansible_file = os.path.join(ansible_fixes_dir, filename)
            conflicts.extend(check_ansible_file(ansible_file, rule_ids, product))

    # Check the per-profile playbooks directory (fully rendered playbooks)
    ansible_playbooks_dir = os.path.join(build_dir, "ansible")
    if os.path.exists(ansible_playbooks_dir):
        for filename in os.listdir(ansible_playbooks_dir):
            if not filename.startswith(f"{product}-playbook-") or not filename.endswith(".yml"):
                continue

            ansible_file = os.path.join(ansible_playbooks_dir, filename)
            conflicts.extend(check_ansible_file(ansible_file, rule_ids, product))

    return conflicts


def main():
    """Main function to run the test."""
    parser = argparse.ArgumentParser(
        description="Test that ansible registered variables don't conflict with rule IDs"
    )
    parser.add_argument(
        "--build-dir",
        required=True,
        help="Build directory containing compiled product data"
    )
    parser.add_argument(
        "--product",
        required=True,
        help="Product ID to check"
    )
    args = parser.parse_args()

    # Check if per-profile playbooks exist (required for this test to work)
    ansible_playbooks_dir = os.path.join(args.build_dir, "ansible")
    if not os.path.exists(ansible_playbooks_dir):
        print(f"ERROR: Per-profile playbooks not found at {ansible_playbooks_dir}", file=sys.stderr)
        print("This test requires per-profile playbooks to be built.", file=sys.stderr)
        print("Please build them first with: ninja <product>-profile-playbooks", file=sys.stderr)
        print("Or ensure SSG_ANSIBLE_PLAYBOOKS_ENABLED is ON in cmake configuration.", file=sys.stderr)
        return 1

    playbook_files = [f for f in os.listdir(ansible_playbooks_dir)
                      if f.startswith(f"{args.product}-playbook-") and f.endswith(".yml")]
    if not playbook_files:
        print(f"ERROR: No playbook files found for product {args.product} in {ansible_playbooks_dir}", file=sys.stderr)
        print("Please build them first with: ninja <product>-profile-playbooks", file=sys.stderr)
        return 1

    # Get all rule IDs from the build directory
    rule_ids = get_all_rule_ids(args.build_dir)

    if not rule_ids:
        print("Warning: No rule IDs found in build directory", file=sys.stderr)
        return 0

    # Check ansible files for the specified product
    conflicts = check_ansible_files_for_conflicts(args.build_dir, args.product, rule_ids)

    if conflicts:
        print("ERROR: Found ansible registered variables that conflict with rule IDs:\n",
              file=sys.stderr)
        for conflict in conflicts:
            print(f"  Product: {conflict['product']}", file=sys.stderr)
            print(f"  File: {conflict['file']}", file=sys.stderr)
            print(f"  Registered variable: '{conflict['variable']}'", file=sys.stderr)
            print(f"  Conflicts with rule: '{conflict['conflicting_rule']}'", file=sys.stderr)
            print(f"  Solution: Rename the registered variable in the source ansible remediation", file=sys.stderr)
            print("", file=sys.stderr)
        return 1

    print(f"OK: No ansible variable conflicts found for product {args.product}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
