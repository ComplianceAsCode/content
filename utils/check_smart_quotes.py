#!/usr/bin/python3
import argparse
import pathlib
import sys

# Default set of file extensions to scan. The CTest registration narrows this
# down (currently to profiles) via the --extensions option.
EXTENSIONS = ['adoc', 'conf', 'html', 'json', 'md', 'profile', 'rst', 'template',
              'toml', 'var', 'xml', 'yaml', 'yml']
DEFAULT_EXTENSIONS = ",".join(EXTENSIONS)

EXCLUSIONS = ['/shared/references/', '/logs/', '/tests/data/utils/', '/tests/.mypy_cache/']

# Unicode "smart" (curly) quotes and their ASCII replacements. These trip the
# ansible-test no-smart-quotes sanity test when profile descriptions are rendered
# into the generated Ansible collection role READMEs.
SMART_QUOTES = {
    '‘': "'",   # LEFT SINGLE QUOTATION MARK
    '’': "'",   # RIGHT SINGLE QUOTATION MARK
    '“': '"',   # LEFT DOUBLE QUOTATION MARK
    '”': '"',   # RIGHT DOUBLE QUOTATION MARK
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Print and fix files that contain Unicode "
                                                 "smart quotes")
    parser.add_argument("paths", type=str, nargs="+", help="Paths to check")
    parser.add_argument("--fix", action="store_true",
                        help='If set the program will replace smart quotes with their ASCII '
                             'equivalents.')
    parser.add_argument("--extensions", type=str, default=DEFAULT_EXTENSIONS,
                        help="Comma-separated list of file extensions to scan "
                             "(without the leading dot).")
    return parser.parse_args()


def get_files(path: pathlib.Path, extensions: list) -> list:
    files = list()
    for ext in extensions:
        files.extend(list(path.glob(f"**/*.{ext}")))
    return files


def get_all_files(paths: list, extensions: list) -> list:
    files = list()
    for path in paths:
        p = pathlib.Path(path)
        if not p.exists():
            sys.stderr.write(f"The path {p.absolute()} does not exist!\n")
            continue
        files.extend(get_files(p, extensions))
    return files


def should_skip_file(file: pathlib.Path) -> bool:
    for exclude in EXCLUSIONS:
        if exclude in str(file.absolute()):
            return True
    return False


def find_smart_quotes(files: list) -> dict:
    bad_files = dict()
    for file in files:
        if should_skip_file(file):
            continue
        try:
            content = file.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        locations = list()
        for line_number, line in enumerate(content.splitlines(), start=1):
            for column, char in enumerate(line, start=1):
                if char in SMART_QUOTES:
                    locations.append((line_number, column, char))
        if locations:
            bad_files[file] = locations
    return bad_files


def fix_file(file: pathlib.Path) -> None:
    content = file.read_text(encoding="utf-8")
    for smart, ascii_char in SMART_QUOTES.items():
        content = content.replace(smart, ascii_char)
    file.write_text(content, encoding="utf-8")


def main() -> int:
    args = parse_args()
    extensions = [ext.strip() for ext in args.extensions.split(",") if ext.strip()]
    files = get_all_files(args.paths, extensions)
    bad_files = find_smart_quotes(files)
    count = len(bad_files)
    for bad_file, locations in bad_files.items():
        for line_number, column, char in locations:
            print(f"{bad_file.absolute()}:{line_number}:{column}: "
                  f"use ASCII quotes ' and \" instead of Unicode quote {char!r}")
        if args.fix:
            fix_file(bad_file)

    print(f"{count} of {len(files)} files contain Unicode smart quotes.")
    if count != 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
