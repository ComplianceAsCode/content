#!/usr/bin/env python2

from __future__ import print_function

import argparse
import sys
import os

import ssg.build_renumber
import ssg.constants
import ssg.id_translate
import ssg.xml


# This script requires two arguments: an "unlinked" XCCDF file and an ID name
# scheme. This script is designed to convert and synchronize check IDs
# referenced from the XCCDF document for the supported checksystems, which are
# currently OVAL and OCIL.  The IDs are to be converted from strings to
# meaningless numbers.


def parse_args():
    parser = argparse.ArgumentParser(
        description="This script finds check-content files (currently, "
        "OVAL and OCIL) referenced from XCCDF and synchronizes all IDs.")
    parser.add_argument("xccdf_file")
    parser.add_argument("id_name", help="ID naming scheme")

    return parser.parse_args()


def main():
    args = parse_args()
    xccdffile = args.xccdf_file
    idname = args.id_name

    # Step over xccdf file, and find referenced check files
    xccdftree = ssg.xml.parse_file(xccdffile)

    if 'unlinked-ocilref' not in xccdffile:
        ssg.build_renumber.check_that_oval_and_rule_id_match(xccdftree)

    checks = xccdftree.findall(".//{%s}check" % ssg.constants.XCCDF11_NS)

    translator = ssg.id_translate.IDTranslator(idname)

    oval_linker = ssg.build_renumber.OVALFileLinker(translator, xccdftree,
                                                    checks)
    oval_linker.link()
    oval_linker.save_linked_tree()
    oval_linker.link_xccdf()

    ocil_linker = ssg.build_renumber.OCILFileLinker(translator, xccdftree,
                                                    checks)
    ocil_linker.link()
    ocil_linker.save_linked_tree()
    ocil_linker.link_xccdf()

    newxccdffile = xccdffile.replace("unlinked", "linked")
    ssg.xml.ElementTree.ElementTree(xccdftree).write(newxccdffile)
    sys.exit(0)


if __name__ == "__main__":
    main()
