#!/usr/bin/env python3
"""Build the normalized spreadsheet review CSV from comparison artifacts."""

import argparse
import csv
import re
from pathlib import Path
from typing import Dict, List


HEADERS = [
    "Requirement",
    "HTML diff URL",
    "STDOUT from compare_ds.py",
    "Changes",
    "Action Required",
    "notes",
    "Assignee",
    "Status",
    "Link",
    "Pull request",
    "model-proposed-changes",
]

STIG_ID = re.compile(r"\bRHEL-\d{2}-\d{6}\b")


def read_rule_messages(stdout_file: Path) -> Dict[str, str]:
    """Group every compare message by its RHEL STIG ID."""
    messages: Dict[str, List[str]] = {}
    for line in stdout_file.read_text().splitlines():
        rule_id = STIG_ID.search(line)
        if rule_id is None:
            continue
        messages.setdefault(rule_id.group(0), []).append(line.strip())
    return {rule_id: "\n".join(lines) for rule_id, lines in messages.items()}


def build(
    diffs_dir: Path,
    stdout_file: Path,
    output_file: Path,
    html_base_url: str,
) -> int:
    """Write one review row for every changed, added, or removed STIG ID."""
    diff_files = sorted(
        path for path in diffs_dir.iterdir() if path.is_file() and STIG_ID.fullmatch(path.name)
    )
    messages = read_rule_messages(stdout_file)
    rule_ids = sorted(set(messages) | {path.name for path in diff_files})
    if not rule_ids:
        raise SystemExit("no changed STIG IDs found in diff files or comparison stdout")

    diff_ids = {path.name for path in diff_files}
    base_url = html_base_url.rstrip("/")
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with output_file.open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(HEADERS)
        for rule_id in rule_ids:
            html_url = f"{base_url}/{rule_id}.html" if base_url else ""
            writer.writerow(
                [
                    rule_id,
                    html_url if rule_id in diff_ids else "",
                    messages.get(rule_id, ""),
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                ]
            )
    return len(rule_ids)


def main() -> None:
    """Parse arguments and write the normalized review CSV."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("diffs_dir", type=Path, help="directory of per-STIG-ID diff files")
    parser.add_argument("stdout_file", type=Path, help="captured compare_ds.py stdout")
    parser.add_argument("output", type=Path, help="review CSV to write")
    parser.add_argument(
        "--html-base-url",
        default="",
        help="directory URL used to build HTML links, without a trailing slash",
    )
    args = parser.parse_args()
    count = build(args.diffs_dir, args.stdout_file, args.output, args.html_base_url)
    print(f"wrote {args.output} ({count} STIG IDs)")


if __name__ == "__main__":
    main()
