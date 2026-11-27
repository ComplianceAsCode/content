#!/usr/bin/env python3
"""Turn raw `compare_ds.py --disa-content --rule-diffs` output into one markdown report.

Each file in the diffs directory is one unified diff for one STIG ID. This script embeds
every diff verbatim inside a collapsible <details> block so the whole report is a single
git-trackable artifact - no external file host, no spreadsheet, no diff2html step.

Usage:
    build_diff_report.py <compare_ds_diffs_dir> <output.md> \\
        --product rhel9 --from-version v2r8 --to-version v2r9

The output is a skeleton: fill in CaC rule / Classification / Action for each STIG ID by
hand (see reference/02-classify-diffs.md). Never hand-edit the text inside a ```diff fence -
if a diff looks wrong, re-run compare_ds.py and regenerate the report instead.
"""
import argparse
from pathlib import Path


def build(diffs_dir: Path, product: str, from_version: str, to_version: str) -> str:
    files = sorted(p for p in diffs_dir.iterdir() if p.is_file())
    if not files:
        raise SystemExit(f"no diff files found in {diffs_dir}")

    lines = [
        f"# {product} STIG {from_version} -> {to_version} diff report",
        "",
        f"{len(files)} STIG IDs changed. Generated from `{diffs_dir}` - every diff below is "
        "copied verbatim from compare_ds.py output. Do not hand-edit the fenced blocks; "
        "re-run this script against fresh compare_ds.py output instead.",
        "",
        "---",
        "",
    ]
    for path in files:
        stig_id = path.name
        diff_text = path.read_text().rstrip("\n")
        lines += [
            f"## {stig_id}",
            "",
            "CaC rule: `TODO`",
            "Classification: `TODO`  <!-- prose | oval | new-rule | removal | control-file | no-action -->",
            "",
            "<details>",
            f"<summary>Diff: {stig_id}</summary>",
            "",
            "```diff",
            diff_text,
            "```",
            "",
            "</details>",
            "",
            "Action: TODO",
            "",
            "---",
            "",
        ]
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("diffs_dir", type=Path, help="directory of per-STIG-ID diff files")
    parser.add_argument("output", type=Path, help="markdown file to write")
    parser.add_argument("--product", required=True, help="e.g. rhel9")
    parser.add_argument("--from-version", dest="from_version", required=True, help="e.g. v2r8")
    parser.add_argument("--to-version", dest="to_version", required=True, help="e.g. v2r9")
    args = parser.parse_args()

    report = build(args.diffs_dir, args.product, args.from_version, args.to_version)
    args.output.write_text(report)
    n = len(list(args.diffs_dir.iterdir()))
    print(f"wrote {args.output} ({n} STIG IDs)")


if __name__ == "__main__":
    main()
