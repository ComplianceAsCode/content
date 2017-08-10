#!/usr/bin/env python2

import sys
import lxml.etree as ET

# This script requires two arguments: an OVAL file and a CPE dictionary file.
# It is designed to extract any inventory definitions and the tests, states,
# objects and variables it references and then write them into a standalone
# OVAL CPE file, along with a synchronized CPE dictionary file.

cpe_ns = "http://cpe.mitre.org/dictionary/2.0"
cce_ns = 'http://cce.mitre.org'


def parse_xml_file(xmlfile):
    with open(xmlfile, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ET.fromstring(filestring)
        # print filestring
    return tree


def main():
    if len(sys.argv) < 3:
        print ("Provide a CCE file and the name of the platform " +
               "whose CCEs to extract.")
        print "This script extracts those CCEs and writes them to STDOUT."
        sys.exit(1)

    ccefile = sys.argv[1]
    platform = sys.argv[2]

    # parse cce file
    ccetree = parse_xml_file(ccefile)

    # extract cces that match the platform name
    platform_cces = ccetree.findall(".//{%s}cce[@platform='%s']"
                                    % (cce_ns, platform))

    cces = ccetree.find("./{%s}cces" % cce_ns)
    resources = ccetree.find("./{%s}resources" % cce_ns)
    cces.clear()
    resources.clear()
    # could include resources that are referenced, if we wanted to bother

    [cces.append(platform_cce) for platform_cce in platform_cces]

    ET.ElementTree(ccetree).write(sys.stdout)

    sys.exit(0)

if __name__ == "__main__":
    main()
