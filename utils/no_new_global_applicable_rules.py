#!/usr/bin/python3

import argparse
import json
import os
import sys
from typing import Set

import ssg.rule_yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root",
                        help=f"Path to the root of the project. Defaults to {SSG_ROOT}",
                        default=SSG_ROOT)
    parser.add_argument("-j", "--json",
                        help=f"Path to rule_dirs.json. Defaults to {RULES_JSON}",
                        default=RULES_JSON)
    return parser.parse_args()


def _get_expected_set() -> set:
    expected_path = os.path.join(SSG_ROOT, 'tests', 'data', 'utils',
                                 'no_new_global_applicable_rules.json')
    with open(expected_path, 'r') as f:
        expected_list = json.load(f)
    expected_set = {rule_id for rule_id in expected_list}
    return expected_set


def _process_current_rule(current_no_prodtypes: set, rule: dict, rule_id: str):
    rule_yaml = ssg.rule_yaml.get_yaml_contents(rule)
    has_prodtype = False
    for line in rule_yaml.contents:
        if 'prodtype:' in line:
            has_prodtype = True
            break
    if not has_prodtype:
        current_no_prodtypes.add(rule_id)


def _get_current_noprodtypes(rule_dirs: dict) -> set:
    current_no_prodtypes: Set[str] = set()
    for rule_id, rule in rule_dirs.items():
        _process_current_rule(current_no_prodtypes, rule, rule_id)
    return current_no_prodtypes


def _get_rule_dir(json_path: str) -> dict:
    if not os.path.exists(json_path):
        print(f"Cannot find rule_dirs.json file at {json_path}.", file=sys.stderr)
        print(f"Hint: run {SSG_ROOT}/utils/rule_dir_json.py", file=sys.stderr)
        exit(1)
    with open(json_path, 'r') as f:
        rule_dirs = json.load(f)
    return rule_dirs


def main():
    args = _parse_args()
    json_path = args.json
    rule_dirs = _get_rule_dir(json_path)
    current_no_prodtypes = _get_current_noprodtypes(rule_dirs)
    expected_set = _get_expected_set()

    delta = current_no_prodtypes - expected_set
    if len(delta) != 0:
        for bad_rule in delta:
            print(f"Rule {bad_rule} doesn't have a prodtype and it is expected to. "
                  f"You must add one.", file=sys.stderr)
        exit(1)


if __name__ == "__main__":
    main()
