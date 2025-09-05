#!/usr/bin/python3

import argparse
import os
import re
import sys
from collections import defaultdict
from typing import Dict, Iterator, List, Pattern

RefsFoundType = "Dict[str, List[str]]"

rx_quoted = re.compile(r'^([\'"])(.*?)\1$')


def recursive_get_rule_files() -> Iterator[str]:
    """Recursive walk whole tree and get rule.yml paths."""
    for root, _, filenames in os.walk("."):
        for filename in filenames:
            full_path = os.path.join(root, filename)
            if os.path.basename(full_path) == "rule.yml":
                yield os.path.normpath(full_path)


def find_rule_file_refs(rule_file: str, rx_ref_line: Pattern[str]) -> Iterator[str]:
    """Find refs per file, either as is or quoted."""
    with open(rule_file, "r") as fd:
        for line in fd:
            match = rx_ref_line.match(line)
            if match:
                found = match.group(1)
                match_quoted = rx_quoted.match(found)
                if match_quoted:
                    found = match_quoted.group(2)
                yield found


def find_refs(ref: str) -> RefsFoundType:
    """Find refs from all rule files."""
    rx_ref_line = re.compile(r"^\s*%s(?:@\w*)?:\s*(.*?)\s*$" % (re.escape(ref)))

    refs_found = defaultdict(list)
    for rule_file in recursive_get_rule_files():
        for found in find_rule_file_refs(rule_file, rx_ref_line):
            refs_found[found].append(rule_file)

    return refs_found


def print_refs(ref: str, refs_found: RefsFoundType) -> bool:
    """
    Print refs and files if ref is found in two or more files.

    Print info into stderr about refs and files if so.
    Returns: True if none found, False if found.
    """
    okay = True

    for dup in sorted(refs_found.keys()):
        filenames = refs_found[dup]
        if len(filenames) > 1:
            okay = False
            print("", file=sys.stderr)
            print(f"{ref} {dup} is included in files: ", file=sys.stderr)
            for filename in sorted(filenames):
                print(f" - {filename}", file=sys.stderr)

    return okay


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("root_ssg_directory", help="Path to root of ssg git repository")
    parser.add_argument("reference", help="Reference to search in rule.yml files")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root_dir = args.root_ssg_directory
    ref = args.reference

    if not os.path.isdir(root_dir):
        print(
            f"ERROR: root_ssg_directory '{root_dir}' is not a directory",
            file=sys.stderr,
        )
        sys.exit(7)

    os.chdir(root_dir)

    refs_found = find_refs(ref)
    okay = print_refs(ref, refs_found)
    sys.exit(0 if okay else 1)


if __name__ == "__main__":
    main()
