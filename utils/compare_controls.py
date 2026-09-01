#!/usr/bin/env python3
"""Compare controls between two YAML control files, ignoring rules/notes/related_rules/status."""

import argparse
import difflib
import sys

import yaml

IGNORED_KEYS = {"rules", "related_rules", "notes", "status"}


def load_controls(path):
    with open(path) as f:
        data = yaml.safe_load(f)
    controls = {}
    for ctrl in data.get("controls", []):
        ctrl_id = ctrl["id"]
        controls[ctrl_id] = {k: v for k, v in ctrl.items() if k not in IGNORED_KEYS}
    return controls


def control_to_lines(ctrl):
    return yaml.dump(ctrl, default_flow_style=False, allow_unicode=True).splitlines(keepends=True)


def main():
    parser = argparse.ArgumentParser(description="Compare controls between two YAML control files.")
    parser.add_argument("file_a", help="First control file")
    parser.add_argument("file_b", help="Second control file")
    args = parser.parse_args()

    controls_a = load_controls(args.file_a)
    controls_b = load_controls(args.file_b)

    ids_a = set(controls_a)
    ids_b = set(controls_b)
    all_ids = sorted(ids_a | ids_b)

    has_diff = False
    for ctrl_id in all_ids:
        a = controls_a.get(ctrl_id)
        b = controls_b.get(ctrl_id)

        if a == b:
            continue

        lines_a = control_to_lines(a) if a else []
        lines_b = control_to_lines(b) if b else []

        diff = list(difflib.unified_diff(
            lines_a, lines_b,
            fromfile=f"{args.file_a}  {ctrl_id}",
            tofile=f"{args.file_b}  {ctrl_id}",
        ))
        if diff:
            has_diff = True
            sys.stdout.writelines(diff)

    sys.exit(1 if has_diff else 0)


if __name__ == "__main__":
    main()
