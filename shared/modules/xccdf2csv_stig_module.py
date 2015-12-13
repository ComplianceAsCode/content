#!/usr/bin/python2

import sys
import csv
import lxml.etree as ET

# This script creates a CSV file from an XCCDF file formatted in the
# structure of a STIG.  This should enable its ingestion into VMS,
# as well as its comparison with VMS output.

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
disa_cciuri = "http://iase.disa.mil/stigs/cci/Pages/index.aspx"
disa_srguri = "http://iase.disa.mil/stigs/srgs/Pages/index.aspx"


def parse_xml_file(xmlfile):
    with open(xmlfile, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ET.fromstring(filestring)
    return tree


def reflist(refs):
    refstring = ', '.join(refs)
    return refstring


def node_to_text(node):
    textslist = node.xpath(".//text()")
    return ''.join(textslist)


def main():
    if len(sys.argv) < 2:
        print "Provide an XCCDF file to convert into a CSV file."
        sys.exit(1)

    xccdffile = sys.argv[1]
    xccdftree = parse_xml_file(xccdffile)
    rules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    rulewriter = csv.writer(sys.stdout, quoting=csv.QUOTE_ALL)

    for rule in rules:
        cci_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % (xccdf_ns, disa_cciuri))]
        srg_refs = [ref.text for ref in rule.findall("{%s}ident[@system='%s']"
                                                     % (xccdf_ns, disa_srguri))]
        title = rule.find("{%s}title" % xccdf_ns).text
        description = node_to_text(rule.find("{%s}description" % xccdf_ns))
        fixtext = node_to_text(rule.find("{%s}fixtext" % xccdf_ns))
        checktext = node_to_text(rule.find(".//{%s}check-content" % xccdf_ns))
        row = [reflist(cci_refs), reflist(srg_refs), title, description, fixtext, checktext]
        rulewriter.writerow(row)

    sys.exit(0)

if __name__ == "__main__":
    main()
