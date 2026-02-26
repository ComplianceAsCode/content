---
name: pdf-reader
description: Extract and read PDF files by converting pages to images with mapped text. Use when the user asks to read, view, inspect, or analyze a PDF file, or when a PDF is too large to read directly.
---

# PDF Reader

Converts PDF pages into per-page PNG images with extracted text. Supports caching so the same PDF is not reprocessed across chats.

## Workflow (always check cache first)

### Step 1: Check if the PDF was already extracted

```bash
python .claude/skills/pdf-reader/scripts/pdf_to_pages.py "path/to/file.pdf" --status
```

Prints `CACHED` with output directory and page ranges, or `NOT_CACHED` if extraction is needed. If cached, skip to Step 3.

### Step 2: Extract pages (only if needed)

The script skips pages already extracted. You can safely expand the range.

```bash
# Extract specific pages (preferred for large PDFs)
python .claude/skills/pdf-reader/scripts/pdf_to_pages.py "path/to/file.pdf" --pages 1-10

# Expand range later — previously extracted pages are skipped
python .claude/skills/pdf-reader/scripts/pdf_to_pages.py "path/to/file.pdf" --pages 1-50

# Full extraction
python .claude/skills/pdf-reader/scripts/pdf_to_pages.py "path/to/file.pdf"

# Force re-extraction (ignores cache)
python .claude/skills/pdf-reader/scripts/pdf_to_pages.py "path/to/file.pdf" --force
```

### Step 3: Read the output

1. **Grep `pages.md`** to find a section heading or keyword
2. **Read page images** (`images/page_NNNN.png`) for visual context
3. **Read `index.txt`** for metadata (source, page count, ranges)

## Output Structure

```
<pdf_name>_pages/
├── pages.md          # Markdown with TOC, images, and text per page
├── index.txt         # Human-readable metadata
├── manifest.json     # Cache fingerprint (mtime, size, dpi, exported pages)
└── images/
    ├── page_0001.png
    └── ...
```

## Caching

- PDF fingerprinted by **mtime + file size**; unchanged PDFs reuse cached images
- Expanding the page range only renders new pages
- Cache invalidates if the PDF is modified or `--dpi` changes
- Use `--force` to bypass

## Options

| Flag | Description |
|------|-------------|
| `--pages 1-10,15` | Page range (1-based). Omit for all pages |
| `--dpi 150` | Image resolution (default: 150) |
| `-o DIR` | Custom output directory |
| `--status` | Check cache status without extracting |
| `--force` | Force re-extraction, ignoring cache |

## Requirements

- Python 3.10+
- `pymupdf` package: `pip install pymupdf`
