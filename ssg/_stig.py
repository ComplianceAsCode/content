#!/usr/bin/env python2

import sys
import csv

from ssg._xml import parse_file as parse_xml_file
from ssg._constants import XCCDF11_NS as xccdf_ns
from ssg._constants import disa_cciuri

# This script creates a CSV file from an XCCDF file formatted in the
# structure of a STIG.  This should enable its ingestion into VMS,
# as well as its comparison with VMS output.


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
    xccdftree = parse_xml_file(xccdffile)
    rules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    rulewriter = csv.writer(sys.stdout, quoting=csv.QUOTE_ALL)

    for rule in rules:
        args = (xccdf_ns, disa_cciuri)
        cci_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % args)]
        srg_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % args)]
        title = rule.find("{%s}title" % xccdf_ns).text
        description = _node_to_text(rule.find("{%s}description" % xccdf_ns))
        fixtext = _node_to_text(rule.find("{%s}fixtext" % xccdf_ns))
        checktext = _node_to_text(rule.find(".//{%s}check-content" % xccdf_ns))
        row = [_reflist(cci_refs), _reflist(srg_refs), title,
               description, fixtext, checktext]
        rulewriter.writerow(row)

    sys.exit(0)


if __name__ == "__main__":
    main()
