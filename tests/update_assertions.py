#!/usr/bin/env python3

import os
import sys
import glob
import yaml
import re
import argparse

# Valid result choices, including an OR case
VALID_RESULTS = [
    "PASS",
    "FAIL",
    "NOT-APPLICABLE",
    "FAIL or NOT-APPLICABLE",
    "PASS or NOT-APPLICABLE"
]

def prompt_user_choice(prompt, choices, allow_empty=False):
    """
    Prompt the user with a set of valid choices, or optionally allow an empty response.
    Returns the user's selection (string).
    If allow_empty is True, user can press Enter to skip (returns '').
    """
    choices_str = "/".join(choices)
    while True:
        user_input = input(f"{prompt} [{choices_str}]{' (or press Enter to skip)' if allow_empty else ''}: ")
        user_input = user_input.strip().upper()
        if allow_empty and user_input == "":
            return ""
        valid_upper = [c.upper() for c in choices]
        if user_input in valid_upper:
            idx = valid_upper.index(user_input)
            return choices[idx]
        print(f"Invalid input. Please choose one of: {choices_str}")


def load_yaml(filepath):
    """Safely load YAML from a file, returning a dict (or empty dict on error)."""
    try:
        with open(filepath, "r") as f:
            data = yaml.safe_load(f)
        if not isinstance(data, dict):
            return {}
        return data
    except Exception as e:
        print(f"Error loading YAML file {filepath}: {e}")
        return {}


def extract_ocp_version(filename):
    """
    Extracts version from the filename by matching a dash followed by something 
    like 4.15, 4.18, etc. Example: 'rhcos4-moderate-4.15.yml' -> '4.15'.
    Returns None if no match is found.
    """
    # We look for a pattern '-X.Y' or '-X.Y.Z', etc. near the end before the .yml
    match = re.search(r'-([\d.]+)\.yml$', os.path.basename(filename))
    if match:
        return match.group(1)
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Update rule assertions in YAML files (interactive or via flags)."
    )
    parser.add_argument("--rule",
                        help="Exact rule name to search for (underscores will be turned into dashes).")
    parser.add_argument("--bulk", action="store_true",
                        help="If specified, apply updates in bulk to all matching assertions.")
    parser.add_argument("--default-result",
                        help="Set this as the new default_result for matching rules.")
    parser.add_argument("--result-after-remediation",
                        help="Set this as the new result_after_remediation for matching rules.")
    parser.add_argument("--exclude-version", action="append", default=[],
                        help="Exclude certain OCP versions from changes. Can be used multiple times.")
    args = parser.parse_args()

    # 1) Get the rule name (either from CLI or prompt)
    if args.rule:
        rule_name = args.rule.strip()
    else:
        rule_name = input("Enter the rule name to search for: ").strip()

    if not rule_name:
        print("No rule name provided. Exiting.")
        sys.exit(0)

    # Replace underscores with dashes in the user rule.
    # We only match if the normalized key ends with this string.
    rule_name = rule_name.replace("_", "-")

    # Path to your assertion files
    assertions_dir = "assertions/ocp4"

    # Collect excluded versions
    exclude_versions = set(args.exclude_version) if args.exclude_version else set()
    if exclude_versions:
        print(f"\nExcluding OCP versions: {', '.join(sorted(exclude_versions))}")

    # Find all YAML files
    yaml_files = glob.glob(os.path.join(assertions_dir, "**/*.yml"), recursive=True)

    # Collect all matches: (yaml_file, key_in_yaml, default_res, remediation_res, version)
    matches = []
    for yf in yaml_files:
        # Extract the OCP version from the filename
        file_version = extract_ocp_version(yf)
        # If version is in the excluded set, skip entirely
        if file_version and file_version in exclude_versions:
            continue

        data = load_yaml(yf)
        rule_results = data.get("rule_results", {})
        if not isinstance(rule_results, dict):
            continue

        # For each key, check if it ends with rule_name after normalizing
        for key, val in rule_results.items():
            normalized_key = key.replace("_", "-")
            if normalized_key.endswith(rule_name):
                dres = val.get("default_result")
                rres = val.get("result_after_remediation")
                matches.append((yf, key, dres, rres, file_version))

    if not matches:
        print(f"\nNo matching rule_results found that end with '{rule_name}' "
              f"(or they were all excluded by version).")
        sys.exit(0)

    # Summarize matches
    print(f"\nFound {len(matches)} matching rule_results that end with '{rule_name}':\n")
    for i, (fpath, key, dres, rres, ver) in enumerate(matches, start=1):
        print(f"{i}. File: {fpath}")
        if ver:
            print(f"   OCP Version: {ver}")
        else:
            print("   OCP Version: <not detected>")
        print(f"   Key: {key}")
        print(f"   default_result: {dres}")
        print(f"   result_after_remediation: {rres if rres else '<not set>'}")
        print("")

    # We'll store changes in memory before writing
    files_to_update = {}  # file_path -> updated_data

    # 2) Decide Bulk or Individual
    if args.bulk:
        do_bulk = True
    else:
        choice = input("Do you want to update ALL of these assertions in bulk? [y/N]: ").strip().lower()
        do_bulk = (choice == "y")

    if do_bulk:
        # 3a) Bulk update
        if args.default_result:
            # Validate
            dr = args.default_result.upper()
            if dr not in [v.upper() for v in VALID_RESULTS]:
                print(f"ERROR: '{args.default_result}' is not a valid result. Choose from {VALID_RESULTS}.")
                sys.exit(1)
            idx = [v.upper() for v in VALID_RESULTS].index(dr)
            new_default_result = VALID_RESULTS[idx]
        else:
            new_default_result = prompt_user_choice("New default_result", VALID_RESULTS)

        if args.result_after_remediation:
            rr = args.result_after_remediation.upper()
            if rr not in [v.upper() for v in VALID_RESULTS]:
                print(f"ERROR: '{args.result_after_remediation}' is not valid. Choose from {VALID_RESULTS}.")
                sys.exit(1)
            idx = [v.upper() for v in VALID_RESULTS].index(rr)
            new_remediation_result = VALID_RESULTS[idx]
        else:
            set_remediation = input("Do you want to set 'result_after_remediation'? [y/N]: ").strip().lower()
            if set_remediation == "y":
                new_remediation_result = prompt_user_choice("New result_after_remediation", VALID_RESULTS)
            else:
                new_remediation_result = ""

        # Apply these updates to all matches
        for (yf, key, _, _, file_version) in matches:
            # Already know file_version is not in excluded set, so proceed
            if yf not in files_to_update:
                files_to_update[yf] = load_yaml(yf)

            data = files_to_update[yf]
            rr = data.get("rule_results", {})
            if key not in rr:
                rr[key] = {}
            rr[key]["default_result"] = new_default_result
            if new_remediation_result:
                rr[key]["result_after_remediation"] = new_remediation_result
            else:
                rr[key].pop("result_after_remediation", None)
            data["rule_results"] = rr

    else:
        # 3b) Individual update
        for i, (yf, key, dres, rres, file_version) in enumerate(matches, start=1):
            print(f"\nMatch #{i} in file: {yf}, key: {key}")
            if file_version:
                print(f"    OCP Version: {file_version}")
            else:
                print("    OCP Version: <not detected>")
            print(f"    Current default_result: {dres}")
            print(f"    Current result_after_remediation: {rres if rres else '<not set>'}")

            if args.default_result:
                df = args.default_result.upper()
                if df not in [v.upper() for v in VALID_RESULTS]:
                    print(f"ERROR: '{args.default_result}' is not valid. Choose from {VALID_RESULTS}.")
                    sys.exit(1)
                idx = [v.upper() for v in VALID_RESULTS].index(df)
                new_default_result = VALID_RESULTS[idx]
                # We assume user wants to update
            else:
                choice = input("    Do you want to update this assertion? [y/N]: ").strip().lower()
                if choice == "y":
                    new_default_result = prompt_user_choice("      New default_result", VALID_RESULTS)
                else:
                    continue

            if args.result_after_remediation:
                r = args.result_after_remediation.upper()
                if r not in [v.upper() for v in VALID_RESULTS]:
                    print(f"ERROR: '{args.result_after_remediation}' is not valid. {VALID_RESULTS}")
                    sys.exit(1)
                idx = [v.upper() for v in VALID_RESULTS].index(r)
                new_remediation_result = VALID_RESULTS[idx]
            else:
                set_r = input("      Do you want to set 'result_after_remediation'? [y/N]: ").strip().lower()
                if set_r == "y":
                    new_remediation_result = prompt_user_choice("      New result_after_remediation", VALID_RESULTS)
                else:
                    new_remediation_result = ""

            if yf not in files_to_update:
                files_to_update[yf] = load_yaml(yf)

            data = files_to_update[yf]
            rr = data.get("rule_results", {})
            if key not in rr:
                rr[key] = {}

            rr[key]["default_result"] = new_default_result
            if new_remediation_result:
                rr[key]["result_after_remediation"] = new_remediation_result
            else:
                rr[key].pop("result_after_remediation", None)

            data["rule_results"] = rr

    # 4) Final confirmation, then write
    if not files_to_update:
        print("\nNo changes were made.")
        sys.exit(0)

    print("\nThe following files would be updated:")
    for fpath in files_to_update:
        print(f"  - {fpath}")

    confirm = input("\nConfirm saving changes to disk? [y/N]: ").strip().lower()
    if confirm != "y":
        print("Changes NOT saved.")
        sys.exit(0)

    # Write to disk
    for fpath, updated_data in files_to_update.items():
        try:
            with open(fpath, "w") as wf:
                yaml.dump(updated_data, wf, sort_keys=False, Dumper=yaml.SafeDumper)
            print(f"Saved: {fpath}")
        except Exception as e:
            print(f"Error writing {fpath}: {e}")

    print("\nAll done. Changes have been saved.")


if __name__ == "__main__":
    main()
