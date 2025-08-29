#!/usr/bin/env python3
import logging
import sys
from typing import List, Dict, Tuple

logging.basicConfig(level=logging.INFO, format="%(message)s")


def handle_detected_updates(file_path: str) -> Tuple[
    List[str],
    List[Dict[str, str]],
    List[str]
]:
    """
    Handle the detected updated files in the file which contains the PR's updated
    files.

    This function processes a file that includes paths of updated files.
    It extracts and categorizes the updated controls, profiles, rules, and variables
    based on the file paths.

    Args:
    file_path (str): The path to the file that contains the list of updated file paths.

    Returns:
        Tuple containing:
        - List of control names
        - List of profile dictionaries (with profile_name and product)
        - List of rule and variable names
    """

    controls: List[str] = []
    profile: Dict[str, str] = {}
    profiles: List[Dict[str, str]] = []
    rules: List[str] = []
    # Open the file and process it line by line
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if 'controls/' in line:
                controlname = line.split('/')[-1].split('.')[0]
                controls.append(controlname)
            elif '.profile' in line:
                profile["profile_name"] = line.split('/')[-1].split('.')[0]
                profile["product"] = line.split('/')[1]
                profiles.append(f'{profile}')
            elif 'rule.yml' in line:
                rulename = line.split('/')[-2]
                rules.append(rulename)
            elif '.var' in line and line.endswith('.var'):
                rulename = line.split('/')[-1].split('.')[0]
                rules.append(rulename)
    controls = handle_controls(controls)
    return controls, profiles, rules


def handle_controls(controls: str) -> str:
    # Handle some special cases
    for i, item in enumerate(controls):
        if "section-" in item:
            controls[i] = "cis_ocp"
        if "SRG-" in item:
            controls.remove(item)
    return list(dict.fromkeys(controls))


def main(file_path):
    controls, profiles, rules = handle_detected_updates(file_path)
    for i in [controls, profiles, rules]:
        logging.info(" ".join(i))


if __name__ == "__main__":
    # Ensure that the script is run with the correct number of arguments
    if len(sys.argv) != 2:
        logging.warning("Usage: \
            python handle_detected_updates.py 'file_path'")
        sys.exit(1)
    # Extract arguments
    file_path = sys.argv[1]  # The argument is file_path
    main(file_path)
