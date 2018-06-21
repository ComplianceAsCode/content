#!/usr/bin/env python2

import sys
import os
import jinja2
import argparse

import ssg


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Utility for fixing mistakes in .rule files",
                                     epilog="""
Commands:
\tempty_identifiers - check and fix rules with empty identifiers
\tprefixed_identifiers - check and fix rules with prefixed (CCE-) identifiers
\tinvalid_identifiers - check and fix rules with invalid identifiers
\tint_identifiers - check and fix rules with pseudo-integer identifiers
\tempty_references - check and fix rules with empty references
\tint_references - check and fix rules with pseduo-integer references
                                     """)
    parser.add_argument("command", help="Which fix to perform.",
                        choices=['empty_identifiers', 'prefixed_identifiers',
                                 'invalid_identifiers', 'int_identifiers',
                                 'empty_references', 'int_references'])
    parser.add_argument("ssg_root", help="Path to root of ssg git directory")
    return parser.parse_args()


def __main__():
    args = parse_args()

    if args.command == 'empty_identifiers':
        ssg.utils_fixes.fix_empty_identifiers(args.ssg_root)
    elif args.command == 'prefixed_identifiers':
        ssg.utils_fixes.find_prefix_cce(args.ssg_root)
    elif args.command == 'invalid_identifiers':
        ssg.utils_fixes.find_invalid_cce(args.ssg_root)
    elif args.command == 'int_identifiers':
        ssg.utils_fixes.find_int_identifiers(args.ssg_root)
    elif args.command == 'empty_references':
        ssg.utils_fixes.fix_empty_references(args.ssg_root)
    elif args.command == 'int_references':
        ssg.utils_fixes.find_int_references(args.ssg_root)
    else:
        sys.exit(1)

if __name__ == "__main__":
    __main__()
