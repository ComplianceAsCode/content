#!/usr/bin/env python2

"""
This script creates a CSV file from an XCCDF file formatted in the
structure of a STIG.  This should enable its ingestion into VMS,
as well as its comparison with VMS output.
"""

from __future__ import absolute_import
from __future__ import print_function

import sys
import csv

import ssg.xml
import ssg.constants


def _reflist(refs):
    refstring = ', '.join(refs)
    return refstring


def _node_to_text(node):
    textslist = node.xpath(".//text()")
    return ''.join(textslist)


def main():
    if len(sys.argv) < 2:
        print("Provide an XCCDF file to convert into a CSV file.")
        sys.exit(1)

    xccdffile = sys.argv[1]
    xccdftree = ssg.xml.parse_file(xccdffile)
    rules = xccdftree.findall(".//{%s}Rule" % ssg.constants.XCCDF11_NS)
    rulewriter = csv.writer(sys.stdout, quoting=csv.QUOTE_ALL)

    for rule in rules:
        args = (ssg.constants.XCCDF11_NS, ssg.constants.disa_cciuri)
        cci_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % args)]
        srg_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % args)]
        title = rule.find("{%s}title" % ssg.constants.XCCDF11_NS).text
        description = _node_to_text(rule.find("{%s}description" % ssg.constants.XCCDF11_NS))
        fixtext = _node_to_text(rule.find("{%s}fixtext" % ssg.constants.XCCDF11_NS))
        checktext = _node_to_text(rule.find(".//{%s}check-content" % ssg.constants.XCCDF11_NS))
        row = [_reflist(cci_refs), _reflist(srg_refs), title,
               description, fixtext, checktext]
        rulewriter.writerow(row)

    sys.exit(0)


if __name__ == "__main__":
    main()
