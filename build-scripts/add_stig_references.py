#!/usr/bin/env python

from __future__ import print_function

import argparse
import ssg.build_stig


def parse_args():
    parser = argparse.ArgumentParser(description='Add STIG references to XCCDF files.')
    parser.add_argument("reference", help="DISA STIG Reference XCCDF file")
    parser.add_argument("input", help="Input XCCDF file path")
    parser.add_argument("output", help="Output XCCDF file path")
    return parser.parse_args()


def main():
    args = parse_args()

    target_root = ssg.build_stig.add_references(args.input, args.reference)
    target_root.write(args.output)


if __name__ == "__main__":
    main()
