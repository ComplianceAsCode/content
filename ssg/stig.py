from __future__ import absolute_import

import sys
import csv

from .xml import parse_file as parse_xml_file
from .constants import disa_cciuri, XCCDF11_NS, stig_ns, stig_refs

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
    rules = xccdftree.findall(".//{%s}Rule" % XCCDF11_NS)
    rulewriter = csv.writer(sys.stdout, quoting=csv.QUOTE_ALL)

    for rule in rules:
        args = (XCCDF11_NS, disa_cciuri)
        cci_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % args)]
        srg_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % args)]
        title = rule.find("{%s}title" % XCCDF11_NS).text
        description = _node_to_text(rule.find("{%s}description" % XCCDF11_NS))
        fixtext = _node_to_text(rule.find("{%s}fixtext" % XCCDF11_NS))
        checktext = _node_to_text(rule.find(".//{%s}check-content" % XCCDF11_NS))
        row = [_reflist(cci_refs), _reflist(srg_refs), title,
               description, fixtext, checktext]
        rulewriter.writerow(row)

    sys.exit(0)


if __name__ == "__main__":
    main()
