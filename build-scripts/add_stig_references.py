#!/usr/bin/env python2

from __future__ import print_function

import argparse
import ssg.build_stig


def parse_args():
    parser = argparse.ArgumentParser(description='Add STIG references to XCCDF files.')
    parser.add_argument("--disa-stig", help="DISA STIG Reference XCCDF file",
                        dest="reference")
    parser.add_argument("--unlinked-xccdf", help="unlinked SSG XCCDF file",
                        dest="destination")
    return parser.parse_args()


def main():
    args = parse_args()

    target_root = ssg.build_stig.add_references(args.reference, args.destination)
    target_root.write(args.destination)


if __name__ == "__main__":
    main()
