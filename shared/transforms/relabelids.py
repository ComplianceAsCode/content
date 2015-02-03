#!/usr/bin/python

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
    # iterate over all checks, grab the OVAL files referenced within
    checkfiles = set()
    for check in checks:
        if check.get("system") == checksystem:
            checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
            checkfiles.add(checkcontentref.get("href"))
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

    checks = xccdftree.findall(".//{%s}check" % xccdf_ns)
    ovalfiles = get_checkfiles(checks, oval_cs)
    ocilfiles = get_checkfiles(checks, ocil_cs)

    if len(ovalfiles) > 1 or len(ocilfiles) > 1:
        sys.exit("referencing more than one file per check system " +
                 "is not yet supported by this script.")
    ovalfile = ovalfiles.pop() if ovalfiles else None
    ocilfile = ocilfiles.pop() if ocilfiles else None

    translator = idtranslate.idtranslator(idname+".ini", idname)

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
        if checkcontentref is None:
            continue

        if check.get("system") == oval_cs:
            checkid = translator.assign_id("{" + oval_ns + "}definition",
                                           checkcontentref.get("name"))
            checkcontentref.set("name", checkid)
            checkcontentref.set("href", newovalfile)
            checkexport = check.find("./{%s}check-export" % xccdf_ns)
            if checkexport is not None:
                newexportname = translator.assign_id("{" + oval_ns + "}variable",
                                                     checkexport.get("export-name"))
                checkexport.set("export-name", newexportname)

        if check.get("system") == ocil_cs:
            checkid = translator.assign_id("{" + ocil_ns + "}questionnaire",
                                           checkcontentref.get("name"))
            checkcontentref.set("name", checkid)
            checkcontentref.set("href", newocilfile)
            checkexport = check.find("./{%s}check-export" % xccdf_ns)
            if checkexport is not None:
                newexportname = translator.assign_id("{" + oval_ns + "}variable",
                                                     checkexport.get("export-name"))
                checkexport.set("export-name", newexportname)

    newxccdffile = xccdffile.replace("unlinked", idname)
    # ET.dump(xccdftree)
    ET.ElementTree(xccdftree).write(newxccdffile)
    sys.exit(0)

if __name__ == "__main__":
    main()
