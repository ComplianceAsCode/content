#!/usr/bin/python3

import argparse
import os.path
import sys
import xml.etree.ElementTree as ET

try:
    import ssg.constants
except ImportError:
    print("The ssg module could not be found.")
    print("Run .pyenv.sh available in the project root directory,"
          " or add it to PYTHONPATH manually.")
    print("$ source .pyenv.sh")
    exit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compare two DISA XML files to find the "
                                                 "differences.")
    parser.add_argument('base_path', help="The path to older XML document")
    parser.add_argument('target_path', help="The path to newer XML document")
    return parser.parse_args()


def get_rules(path: str) -> set:
    rules = set()
    root = ET.parse(path).getroot()
    groups = root.findall('xccdf-1.1:Group', ssg.constants.PREFIX_TO_NS)
    for group in groups:
        for stig in group.findall('xccdf-1.1:Rule', ssg.constants.PREFIX_TO_NS):
            stig_id = stig.find('xccdf-1.1:version', ssg.constants.PREFIX_TO_NS).text
            rules.add(stig_id)
    return rules


def check_paths(args: argparse.Namespace) -> None:
    if not os.path.exists(args.base_path) or not os.path.isfile(args.base_path):
        sys.stderr.write(f'Base path: {args.base_path} does not exist or is not a file.')
        exit(2)
    if not os.path.exists(args.target_path) or not os.path.isfile(args.target_path):
        sys.stderr.write(f'Target path: {args.target_path} does not exist or is not a file. '
                         f'{os.path.exists(args.target_path)}')
        exit(3)


def main():
    args = parse_args()
    check_paths(args)
    base_rules = get_rules(args.base_path)
    target_rules = get_rules(args.target_path)
    new_rules = target_rules - base_rules
    removed_rules = base_rules - target_rules
    print(f'Base count: {len(base_rules)}')
    print(f'Target count: {len(target_rules)}')
    print(f"New rules: ({len(new_rules)})")
    for rule in new_rules:
        print(f'\t{rule}')

    print(f"Removed rules ({len(removed_rules)})")
    for rule in removed_rules:
        print(f'\t{rule}')


if __name__ == '__main__':
    main()
