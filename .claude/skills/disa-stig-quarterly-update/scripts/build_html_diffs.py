#!/usr/bin/env python3
"""Render retained per-STIG unified diffs as HTML with ``diff2html``."""

import argparse
import shutil
import subprocess
from pathlib import Path


def build(diffs_dir: Path, output_dir: Path) -> int:
    """Render every diff file and return the number of generated HTML files."""
    diff2html = shutil.which("diff2html")
    if diff2html is None:
        raise SystemExit(
            "diff2html is not installed; keep the raw diffs and install diff2html before "
            "rendering HTML artifacts"
        )

    files = sorted(path for path in diffs_dir.iterdir() if path.is_file())
    if not files:
        raise SystemExit(f"no diff files found in {diffs_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)
    for diff_file in files:
        output_file = output_dir / f"{diff_file.name}.html"
        # Use file-input mode so the HTML is rendered directly from the retained raw diff.
        subprocess.run(
            [
                diff2html,
                "-i",
                "file",
                "-t",
                diff_file.name,
                "-F",
                str(output_file),
                "--",
                str(diff_file),
            ],
            check=True,
        )
    return len(files)


def main() -> None:
    """Parse arguments and render the retained HTML diff artifacts."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("diffs_dir", type=Path, help="directory of per-STIG-ID diff files")
    parser.add_argument("output_dir", type=Path, help="directory for generated HTML files")
    args = parser.parse_args()
    count = build(args.diffs_dir, args.output_dir)
    print(f"wrote {count} HTML diffs to {args.output_dir}")


if __name__ == "__main__":
    main()
