#!/usr/bin/python2

import sys
import os
import idtranslate
import lxml.etree as ET

# This script requires two arguments: an "unlinked" XCCDF file and an ID name
# scheme. This script is designed to convert and synchronize check IDs
# referenced from the XCCDF document for the supported checksystems, which are
# currently OVAL and OCIL.  The IDs are to be converted from strings to
# meaningless numbers.


oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
oval_cs = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
ocil_ns = "http://scap.nist.gov/schema/ocil/2.0"
ocil_cs = "http://scap.nist.gov/schema/ocil/2"
xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"


def parse_xml_file(xmlfile):
    with open(xmlfile, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ET.fromstring(filestring)
        # print filestring
    return tree


def get_checkfiles(checks, checksystem):
    # Iterate over all checks, grab the OVAL files referenced within
    checkfiles = set()
    for check in checks:
        if check.get("system") == checksystem:
            checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
            checkcontentref_hrefattr = checkcontentref.get("href")
            # Include the file in the particular check system only if it's NOT
            # a remotely located file (to allow OVAL checks to reference http://
            # and https:// formatted URLs)
            if not checkcontentref_hrefattr.startswith("http://") and \
               not checkcontentref_hrefattr.startswith("https://"):
                checkfiles.add(checkcontentref_hrefattr)
    return checkfiles


def main():
    if len(sys.argv) < 3:
        print "Provide an XCCDF file and an ID name scheme."
        print ("This script finds check-content files (currently, OVAL " +
               "and OCIL) referenced from XCCDF and synchronizes all IDs.")
        sys.exit(1)

    xccdffile = sys.argv[1]
    idname = sys.argv[2]

    os.chdir("./output")
    # step over xccdf file, and find referenced check files
    xccdftree = parse_xml_file(xccdffile)

    # Check that OVAL IDs and XCCDF Rule IDs match
    if 'unlinked-ocilref' not in xccdffile:
        allrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
        for rule in allrules:
            xccdf_rule = rule.get("id")
            if xccdf_rule is not None:
                checks = rule.find("./{%s}check" % xccdf_ns)
                if checks is not None:
                    for check in checks:
                        oval_id = check.get("name")
                        if not xccdf_rule == oval_id and oval_id is not None \
                            and not xccdf_rule == 'sample_rule':
                            print("The OVAL ID does not match the XCCDF Rule ID!\n"
                                  "\n  OVAL ID:       \'%s\'"
                                  "\n  XCCDF Rule ID: \'%s\'"
                                  "\n\nBoth OVAL and XCCDF Rule IDs must match!") % (oval_id, xccdf_rule)
                            sys.exit(1)

    checks = xccdftree.findall(".//{%s}check" % xccdf_ns)
    ovalfiles = get_checkfiles(checks, oval_cs)
    ocilfiles = get_checkfiles(checks, ocil_cs)

    if len(ovalfiles) > 1 or len(ocilfiles) > 1:
        sys.exit("referencing more than one file per check system " +
                 "is not yet supported by this script.")
    ovalfile = ovalfiles.pop() if ovalfiles else None
    ocilfile = ocilfiles.pop() if ocilfiles else None

    translator = idtranslate.idtranslator(idname)

    # rename all IDs in the oval file
    if ovalfile:
        ovaltree = parse_xml_file(ovalfile)
        ovaltree = translator.translate(ovaltree, store_defname=True)
        newovalfile = ovalfile.replace("unlinked", idname)
        ET.ElementTree(ovaltree).write(newovalfile)

    # rename all IDs in the ocil file
    if ocilfile:
        ociltree = parse_xml_file(ocilfile)
        ociltree = translator.translate(ociltree)
        newocilfile = ocilfile.replace("unlinked", idname)
        ET.ElementTree(ociltree).write(newocilfile)

    # rename all IDs and file refs in the xccdf file
    for check in checks:
        checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)

        # Don't attempt to relabel ID on empty <check-content-ref> element
        if checkcontentref is None:
            continue
        # Obtain the value of the 'href' attribute of particular
        # <check-content-ref> element
        checkcontentref_hrefattr = checkcontentref.get("href")

        # Don't attempt to relabel ID on <check-content-ref> element having
        # its "href" attribute set either to "http://" or to "https://" values
        if checkcontentref_hrefattr.startswith("http://") or \
           checkcontentref_hrefattr.startswith("https://"):
            continue

        if check.get("system") == oval_cs:
            checkid = translator.generate_id("{" + oval_ns + "}definition",
                                             checkcontentref.get("name"))
            checkcontentref.set("name", checkid)
            checkcontentref.set("href", newovalfile)
            checkexport = check.find("./{%s}check-export" % xccdf_ns)
            if checkexport is not None:
                newexportname = translator.generate_id("{" + oval_ns + "}variable",
                                                       checkexport.get("export-name"))
                checkexport.set("export-name", newexportname)

        if check.get("system") == ocil_cs:
            checkid = translator.generate_id("{" + ocil_ns + "}questionnaire",
                                             checkcontentref.get("name"))
            checkcontentref.set("name", checkid)
            checkcontentref.set("href", newocilfile)
            checkexport = check.find("./{%s}check-export" % xccdf_ns)
            if checkexport is not None:
                newexportname = translator.generate_id("{" + oval_ns + "}variable",
                                                       checkexport.get("export-name"))
                checkexport.set("export-name", newexportname)

    newxccdffile = xccdffile.replace("unlinked", idname)
    # ET.dump(xccdftree)
    ET.ElementTree(xccdftree).write(newxccdffile)
    sys.exit(0)

if __name__ == "__main__":
    main()
