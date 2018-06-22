#!/usr/bin/python3

import os
import argparse
import sys

import ssg


def parse_args():
    p = argparse.ArgumentParser(
        description="Looks through both source files and built files of the "
        "product and finds shadowed files. Outputs them in the format of "
        "shadowing. For example if D ends up being used and C, B and A are "
        "shadowed it will output A <- B <- C <- D."
    )
    p.add_argument("--product", default="rhel7",
                   help="Which product we should examine for shadowed checks "
                   "and fixes.")
    p.add_argument("ssg_root", help="Path to root of the SSG project.")

    return p.parse_args()


def main():
    args = parse_args()

    check_languages = ["oval"]
    fix_languages = ["bash", "ansible", "anaconda", "puppet"]

    for product in [args.product]:
        for check_lang in check_languages:
            print("%s %s check shadows" % (product, check_lang))
            ssg.utils_shadowed.print_shadows("checks", check_lang, product, args.ssg_root)
            print()

        print()

        for fix_lang in fix_languages:
            print("%s %s fix shadows" % (product, fix_lang))
            ssg.utils_shadowed.print_shadows("fixes", fix_lang, product, args.ssg_root)
            print()


if __name__ == "__main__":
    main()
