#!/usr/bin/python

import sys, os, optparse
import lxml.etree as ET

#
# This script can verify consistency of references (linkage) between XCCDF and
# OVAL, and also search based on other criteria such as existence of policy
# references in XCCDF.
#

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1" 
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"

def parse_options():
    usage = "usage: %prog [options] xccdf_file"
    parser = optparse.OptionParser(usage=usage, version="%prog ")
    # only some options are on by default
    parser.add_option("--rules_with_invalid_checks", default=True, action="store_true", dest="rules_with_invalid_checks",
                      help="print XCCDF Rules that reference an invalid/nonexistent check")
    parser.add_option("--rules_without_checks", default=True, action="store_true", dest="rules_without_checks",
                      help="print XCCDF Rules that do not include a check")
    parser.add_option("--rules_without_nistrefs", default=False, action="store_true", dest="rules_without_nistrefs",
                      help="print XCCDF Rules which do not include any NIST 800-53 references")
    parser.add_option("--ovaldefs_unused", default=False, action="store_true", dest="ovaldefs_unused",
                      help="print OVAL definitions which are not used by any XCCDF Rule")
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.print_help()
        sys.exit(1)
    return (options, args)

def get_ovalfiles(checks):
    # iterate over all checks, grab the OVAL files referenced within
    ovalfiles = set()
    for check in checks:
        if check.get("system") == oval_ns:
            checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
            ovalfiles.add(checkcontentref.get("href"))
        else:
            print "Non-OVAL checking system found: " + check.get("system")
    return ovalfiles


def main():
    (options, args) = parse_options()
    xccdffilename = args[0]

    xccdftree = ET.parse(xccdffilename)
    rules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)

    # step over xccdf file, and find referenced oval files
    checks = xccdftree.findall(".//{%s}check" % xccdf_ns)
    ovalfiles = get_ovalfiles(checks)

    if len(ovalfiles) > 1:
        sys.exit("Referencing more than one OVAL file is not yet supported by this script.")
    ovalfile = ovalfiles.pop()
    ovaltree = ET.parse(ovalfile) 

    # actually do the verification work here
    if options.rules_with_invalid_checks:
        print "do processing to find invalid checks here"
    if options.rules_without_checks:
        print "do processing to find rules without checks here"
    if options.rules_without_nistrefs:
        print "do processing to find rules without nistrefs here"
    if options.ovaldefs_unused:
        print "do processing to find ovaldefs unused by any rules"

    sys.exit(0)

if __name__ == "__main__":
    main()

