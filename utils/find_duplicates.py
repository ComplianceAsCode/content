#!/usr/bin/env python2
"""
    This script should find duplicates e.g. specific template is same as shared one
"""
import sys
import os
import re
import glob
import argparse
import ssg


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("root_ssg_directory", help="Path to root of ssg git repository")
    return parser.parse_args()


def main():
    """
    main function
    """
    args = parse_args()
    root_dir = args.root_ssg_directory
    without_duplicates = True

    # Static bash scripts
    print("Static bash files:")
    static_bash_finder = ssg.utils_duplicates.BashDuplicatesFinder(
        root_dir,
        os.path.join("**", "fixes", "bash"),
        os.path.join("shared", "fixes", "bash")
    )
    if static_bash_finder.search():
        without_duplicates = False

    # Templates bash scripts
    print("Bash templates:")
    template_bash_finder = ssg.utils_duplicates.BashDuplicatesFinder(
        root_dir,
        os.path.join("**", "templates"),
        os.path.join("shared", "templates"),
        "template_BASH_*"
    )
    if template_bash_finder.search():
        without_duplicates = False

    # Static oval files
    print("Static oval files:")
    static_oval_finder = ssg.utils_duplicates.OvalDuplicatesFinder(
        root_dir,
        os.path.join("**", "checks", "oval"),
        os.path.join("shared", "checks", "oval")
    )
    if static_oval_finder.search():
        without_duplicates = False

    # Templates oval files
    print("Templates oval files:")
    templates_oval_finder = ssg.utils_duplicates.OvalDuplicatesFinder(
        root_dir,
        os.path.join("**", "templates"),
        os.path.join("shared", "templates"),
        "template_OVAL_*"
    )

    if templates_oval_finder.search():
        without_duplicates = False

    # Scan results
    if without_duplicates:
        print("No duplicates found")
        sys.exit(0)
    else:
        print("Duplicates found!")
        sys.exit(1)


if __name__ == "__main__":
    main()
