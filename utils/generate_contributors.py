#!/usr/bin/python3

import argparse
import os.path
import codecs
import ssg
import ssg.contributors


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dry-run', action="store_true",
                        help="If set the script will not output.")
    return parser.parse_args()


def main():
    args = parse_args()

    contributors_md, contributors_xml = ssg.contributors.generate()

    if args.dry_run:
        exit(0)

    root_dir = os.path.dirname(os.path.dirname(__file__))
    with codecs.open(os.path.join(root_dir, "Contributors.md"),
                     mode="w", encoding="utf-8") as f:
        f.write(contributors_md)

    with codecs.open(os.path.join(root_dir, "Contributors.xml"),
                     mode="w", encoding="utf-8") as f:
        f.write(contributors_xml)

    print("Don't forget to commit Contributors.md and Contributors.xml!")


if __name__ == "__main__":
    main()
