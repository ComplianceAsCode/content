#!/usr/bin/env python2

import sys
import os
import os.path
import argparse

import ssg.build_remediations as remediation
import ssg.rules
import ssg.jinja
import ssg.yaml
import ssg.utils
import ssg.xml


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--remediation_type", required=True,
                   help="language or type of the remediations we are combining."
                   "example: ansible")
    p.add_argument("--build_dir", required=True,
                   help="where is the cmake build directory. pass value of "
                   "$CMAKE_BINARY_DIR.")
    p.add_argument("--output", type=argparse.FileType("wb"), required=True)
    p.add_argument("fixdir", metavar="FIX_DIR",
                   help="directory from which we will collect "
                   "remediations to combine.")

    return p.parse_args()


def main():
    args = parse_args()

    if not os.path.isdir(args.fixdir):
        sys.stderr.write("Directory %s does not exist" % args.fixdir)
        sys.exit(1)

    fixes = dict()
    for filename in os.listdir(args.fixdir):
        file_path = os.path.join(args.fixdir, filename)
        fix_name, _ = os.path.splitext(filename)
        result = remediation.parse_from_file_without_jinja(file_path)
        fixes[fix_name] = result

    remediation.write_fixes_to_xml(args.remediation_type, args.build_dir,
                                   args.output, fixes)

    sys.exit(0)


if __name__ == "__main__":
    main()
