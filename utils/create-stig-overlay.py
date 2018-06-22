#!/usr/bin/env python2

from __future__ import print_function

import re
import sys
import argparse
import os

import ssg


def parse_args():
    outfile = "stig_overlay.xml"
    parser = argparse.ArgumentParser()
    parser.add_argument("--disa-xccdf", default=False, required=True,
                        action="store", dest="disa_xccdf_filename",
                        help="A DISA generated XCCDF Manual checks file. \
                              For example: disa-stig-rhel6-v1r12-xccdf-manual.xml")
    parser.add_argument("--ssg-xccdf", default=None,
                        action="store", dest="ssg_xccdf_filename",
                        help="A SSG generated XCCDF file. \
                              For example: ssg-rhel6-xccdf.xml")
    parser.add_argument("-o", "--output", default=outfile,
                        action="store", dest="output_file",
                        help="STIG overlay XML content file \
                             [default: %default]")
    return parser.parse_args()


def main():
    args = parse_args()

    disa_xccdftree = ssg.xml.ElementTree.parse(args.disa_xccdf_filename)

    if not args.ssg_xccdf_filename:
        print("WARNING: You are generating a STIG overlay XML file without mapping it "
              "to existing SSG content.")
        prompt = ssg.utils.yes_no_prompt()
        if not prompt:
            sys.exit(0)
        ssg_xccdftree = False
    else:
        ssg_xccdftree = ssg.xml.ElementTree.parse(args.ssg_xccdf_filename)
        ssg_name = ssg_xccdftree.find(".//{%s}publisher" % ssg.constants.dc_ns).text
        if ssg_name != "SCAP Security Guide Project":
            sys.exit("%s is not a valid SSG generated XCCDF file." % args.ssg_xccdf_filename)

    disa = disa_xccdftree.find(".//{%s}source" % ssg.constants.dc_ns).text
    if disa != "STIG.DOD.MIL":
        sys.exit("%s is not a valid DISA generated manual XCCDF file." % args.disa_xccdf_filename)

    ssg.utils_overlay.new_stig_overlay(disa_xccdftree, ssg_xccdftree, args.output_file)


if __name__ == "__main__":
    main()
