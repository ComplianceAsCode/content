#!/usr/bin/python3
import _io
import argparse
import os
import sys
import yaml

import ssg.controls
from utils.create_srg_export import get_env_yaml, get_policy

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")


def check_selection(product: str, selection: str) -> None:
    rule_file = os.path.join(SSG_ROOT, 'build', product, 'rules', f'{selection}.yml')
    with open(rule_file, 'r') as f:
        check_fields(f, selection)


def check_fields(f: _io.TextIOWrapper, selection: str):
    rule_yaml = yaml.load(Loader=yaml.SafeLoader, stream=f)
    if rule_yaml.get('fixtext', '') == '' or rule_yaml['fixtext'] is None:
        print(f'{selection} is missing fixtext')
    if rule_yaml.get('ocil', '') == '' or rule_yaml['ocil'] is None:
        print(f'{selection} is missing ocil')
    if rule_yaml.get('ocil_clause', '') == '' or rule_yaml['ocil_clause'] is None:
        print(f'{selection} is missing ocil_clause')
    if rule_yaml.get('srg_requirement', '') == '' or rule_yaml['srg_requirement'] is None:
        print(f'{selection} is missing srg_requirement')


def check_files(control: str, control_main_path: str) -> None:
    if not os.path.exists(control_main_path):
        sys.stderr.write(f"Unable to find control {control}\n")
        exit(1)


def check_selections(product: str, control: ssg.controls.Control) -> None:
    for selection in control.selections:
        if selection in control.selected:
            check_selection(product, selection)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--srg', help="What SRG ID to check")
    parser.add_argument('-c', '--control', required=True, help='Id of the control to load')
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product to get STIGs for")
    parser.add_argument("-b", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration.")
    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    check_files(args.control, args.control)
    env_yaml = get_env_yaml(args.root, args.product, args.build_config_yaml)
    policy = get_policy(args, env_yaml)
    for control in policy.controls:
        if args.srg is not None and control.id != args.srg:
            continue
        check_selections(args.product, control)


if __name__ == '__main__':
    main()
