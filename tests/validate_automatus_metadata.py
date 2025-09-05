#!/usr/bin/python3

import argparse
import os
import glob
import sys

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VALID_FIELDS = ['check', 'packages', 'platform', 'profiles', 'remediation', 'templates',
                'variables']
VALID_STATES = ['pass', 'fail', 'notapplicable']


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root", required=False, default=SSG_ROOT,
                        help="Root directory of the project")
    return parser.parse_args()


def get_files(root: str):
    result = glob.glob("linux_os/**/tests/*.sh", recursive=True, root_dir=root)
    return result


def _test_filename_valid(test_file: str) -> bool:
    filename = os.path.basename(test_file)
    end_state = filename.split('.')
    if len(end_state) == 3 and end_state[1] not in VALID_STATES:
        print(f"Invalid expected state '{end_state[1]}' in {test_file}", file=sys.stderr)
        return False
    return True


def _has_invalid_param(root: str, test_file: str) -> bool:
    full_path = os.path.join(root, test_file)
    with open(full_path, "r") as f:
        for line in f:
            if not line.startswith("#"):
                break
            line = line.removeprefix('#')
            line = line.strip()
            parts = line.split('=')
            if len(parts) != 2:
                continue
            param_name = parts[0].strip()
            if param_name not in VALID_FIELDS:
                print(f"Invalid field '{param_name}' in {test_file}", file=sys.stderr)
                return False
    return True


def main() -> int:
    args = _parse_args()
    test_files = get_files(args.root)
    return_value = 0
    for test_file in test_files:
        if not _test_filename_valid(test_file):
            return_value = 1
        if not _has_invalid_param(args.root, test_file):
            return_value = 1
    return return_value


if __name__ == "__main__":
    raise SystemExit(main())
