#!/usr/bin/env python3
"""Extract PDF pages into a Markdown file with per-page images and text.

Supports incremental extraction: skips pages already exported if the PDF
has not changed (matched by mtime + file size fingerprint).
"""

import argparse
import json
import os
import sys

import pymupdf

MANIFEST_NAME = "manifest.json"


def pdf_fingerprint(pdf_path: str) -> dict:
    st = os.stat(pdf_path)
    return {"path": pdf_path, "mtime": st.st_mtime, "size": st.st_size}


def load_manifest(output_dir: str) -> dict | None:
    mf_path = os.path.join(output_dir, MANIFEST_NAME)
    if not os.path.isfile(mf_path):
        return None
    with open(mf_path) as f:
        return json.load(f)


def save_manifest(output_dir: str, fingerprint: dict, total_pages: int, exported: list[int], dpi: int):
    mf_path = os.path.join(output_dir, MANIFEST_NAME)
    data = {
        "fingerprint": fingerprint,
        "total_pages": total_pages,
        "dpi": dpi,
        "exported_pages": sorted(set(exported)),
    }
    with open(mf_path, "w") as f:
        json.dump(data, f, indent=2)


def main():
    parser = argparse.ArgumentParser(description="Extract PDF into page images + text markdown")
    parser.add_argument("pdf", help="Path to the PDF file")
    parser.add_argument("-o", "--output", help="Output directory (default: <pdf_name>_pages/ next to PDF)")
    parser.add_argument("--dpi", type=int, default=150, help="Image resolution (default: 150)")
    parser.add_argument("--pages", help="Page range, e.g. '1-10' or '5' or '3,7,12'")
    parser.add_argument("--force", action="store_true", help="Force re-extraction even if cached")
    parser.add_argument("--status", action="store_true", help="Print cache status and exit without extracting")
    args = parser.parse_args()

    pdf_path = os.path.abspath(args.pdf)
    if not os.path.isfile(pdf_path):
        print(f"Error: file not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)

    basename = os.path.splitext(os.path.basename(pdf_path))[0]
    output_dir = args.output or os.path.join(os.path.dirname(pdf_path), f"{basename}_pages")

    fp = pdf_fingerprint(pdf_path)
    manifest = load_manifest(output_dir)

    cache_valid = (
        manifest is not None
        and not args.force
        and manifest.get("fingerprint", {}).get("mtime") == fp["mtime"]
        and manifest.get("fingerprint", {}).get("size") == fp["size"]
        and manifest.get("dpi") == args.dpi
    )

    if args.status:
        if cache_valid:
            exported = manifest["exported_pages"]
            print(f"CACHED: {output_dir}")
            print(f"  pages_exported: {len(exported)} of {manifest['total_pages']}")
            print(f"  dpi: {manifest['dpi']}")
            print(f"  pages: {_format_page_ranges(exported)}")
        else:
            reason = "no cache" if manifest is None else "pdf changed or dpi mismatch"
            print(f"NOT_CACHED: {reason}")
        return

    os.makedirs(output_dir, exist_ok=True)
    img_dir = os.path.join(output_dir, "images")
    os.makedirs(img_dir, exist_ok=True)

    doc = pymupdf.open(pdf_path)
    total = len(doc)

    requested: list[int] = []
    if args.pages:
        for part in args.pages.split(","):
            part = part.strip()
            if "-" in part:
                start, end = part.split("-", 1)
                start_i = max(0, int(start) - 1)
                end_i = min(total, int(end))
                requested.extend(range(start_i, end_i))
            else:
                idx = int(part) - 1
                if 0 <= idx < total:
                    requested.append(idx)
    else:
        requested = list(range(total))

    previously_exported: set[int] = set()
    if cache_valid:
        previously_exported = set(manifest.get("exported_pages", []))

    to_extract = [i for i in requested if i not in previously_exported]

    if not to_extract and cache_valid:
        md_path = os.path.join(output_dir, "pages.md")
        print(f"All {len(requested)} requested pages already cached in: {output_dir}", file=sys.stderr)
        print(f"  Markdown: {md_path}", file=sys.stderr)
        print(f"  Use --force to re-extract", file=sys.stderr)
        print(md_path)
        doc.close()
        return

    zoom = args.dpi / 72
    mat = pymupdf.Matrix(zoom, zoom)

    new_count = 0
    skip_count = 0
    for i in requested:
        page_num = i + 1
        img_filename = f"page_{page_num:04d}.png"
        img_path = os.path.join(img_dir, img_filename)

        if i in previously_exported and os.path.isfile(img_path):
            skip_count += 1
            continue

        page = doc[i]
        pix = page.get_pixmap(matrix=mat)
        pix.save(img_path)
        new_count += 1
        print(f"[{page_num}/{total}] Exported page {page_num} -> {img_filename}", file=sys.stderr)

    doc.close()

    all_exported = sorted(set(requested) | previously_exported)

    _rebuild_markdown(pdf_path, basename, output_dir, img_dir, all_exported, total)

    save_manifest(output_dir, fp, total, all_exported, args.dpi)

    _write_index(output_dir, pdf_path, total, all_exported, img_dir)

    md_path = os.path.join(output_dir, "pages.md")
    print(f"\nDone. Output in: {output_dir}", file=sys.stderr)
    print(f"  New: {new_count}, Cached: {skip_count}", file=sys.stderr)
    print(f"  Markdown: {md_path}", file=sys.stderr)
    print(f"  Images:   {img_dir}/ ({len(all_exported)} PNGs)", file=sys.stderr)
    print(md_path)


def _rebuild_markdown(pdf_path, basename, output_dir, img_dir, page_indices, total):
    """Rebuild pages.md including text for all exported pages."""
    doc = pymupdf.open(pdf_path)

    md_lines: list[str] = []
    md_lines.append(f"# {basename}\n")
    md_lines.append(f"**Source:** `{pdf_path}`  ")
    md_lines.append(f"**Pages:** {len(page_indices)} of {total}\n")
    md_lines.append("## Table of Contents\n")
    for i in page_indices:
        md_lines.append(f"- [Page {i + 1}](#page-{i + 1})")
    md_lines.append("")

    for i in page_indices:
        page = doc[i]
        page_num = i + 1
        img_filename = f"page_{page_num:04d}.png"
        text = page.get_text("text").strip()

        md_lines.append(f"---\n")
        md_lines.append(f"## Page {page_num}\n")
        md_lines.append(f"![Page {page_num}](images/{img_filename})\n")
        if text:
            md_lines.append("<details>")
            md_lines.append(f"<summary>Page {page_num} text ({len(text)} chars)</summary>\n")
            md_lines.append("```")
            md_lines.append(text)
            md_lines.append("```\n")
            md_lines.append("</details>\n")
        else:
            md_lines.append("*No extractable text on this page.*\n")

    doc.close()

    md_path = os.path.join(output_dir, "pages.md")
    with open(md_path, "w") as f:
        f.write("\n".join(md_lines))


def _write_index(output_dir, pdf_path, total, exported, img_dir):
    index_path = os.path.join(output_dir, "index.txt")
    with open(index_path, "w") as f:
        f.write(f"source: {pdf_path}\n")
        f.write(f"total_pages: {total}\n")
        f.write(f"exported_pages: {len(exported)}\n")
        f.write(f"exported_range: {_format_page_ranges(exported)}\n")
        f.write(f"output_dir: {output_dir}\n")
        f.write(f"markdown: {os.path.join(output_dir, 'pages.md')}\n")
        f.write(f"image_dir: {img_dir}\n")


def _format_page_ranges(indices: list[int]) -> str:
    """Format [0,1,2,5,6,9] as '1-3,6-7,10' (1-based)."""
    if not indices:
        return "none"
    pages = sorted(set(i + 1 for i in indices))
    ranges: list[str] = []
    start = prev = pages[0]
    for p in pages[1:]:
        if p == prev + 1:
            prev = p
        else:
            ranges.append(f"{start}-{prev}" if start != prev else str(start))
            start = prev = p
    ranges.append(f"{start}-{prev}" if start != prev else str(start))
    return ",".join(ranges)


if __name__ == "__main__":
    main()
