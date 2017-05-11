#!/usr/bin/python


import sys
import optparse
import lxml.etree as ET

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"


def main():
    if len(sys.argv) < 2:
       print("Provide an unlinked xccdf file which contains fixes.")
       sys.exit(1)

    xccdffilename = sys.argv[1]

    xccdftree = ET.parse(xccdffilename)
    allrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    for rule in allrules:
        xccdf_rule = rule.get("id")
        if xccdf_rule is not None:
            checks = rule.find("./{%s}check" % xccdf_ns)
            if checks is not None:
                for check in checks:
                    oval_id = check.get("name")
                    if not xccdf_rule == oval_id and oval_id is not None:
                        print("The OVAL ID does not match the XCCDF Rule ID!\n"
                              "\n  OVAL ID:       \'%s\'"
                              "\n  XCCDF Rule ID: \'%s\'"
                              "\n\nBoth OVAL and XCCDF IDs must match!") % (oval_id, xccdf_rule)
                        sys.exit(1)


if __name__ == "__main__":
    main()

