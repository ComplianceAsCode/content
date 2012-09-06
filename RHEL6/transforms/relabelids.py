#!/usr/bin/python

import sys, os
import idtranslate
import lxml.etree as ET

# This script requires two arguments: an XCCDF file and an ID name scheme.
# This script is designed to convert and synchronize all IDs referenced from the XCCDF document.
# These references would typically be inside OVAL documents, but we also looking to OCIL.
# The IDs are to be converted from strings to meaningless numbers.

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
xccdf_ns = "http://checklists.nist.gov/xccdf/1.1" 


def parse_xml_file(xmlfile):
    with open( xmlfile, 'r') as f:
        filestring = f.read()
        tree = ET.fromstring(filestring)  
        #print filestring
    return tree


def get_ovalfiles(checks):
    # iterate over all checks, grab the OVAL files referenced within
    ovalfiles = set()
    for check in checks:
        if check.get("system") == oval_ns:
            checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
            ovalfiles.add(checkcontentref.get("href"))
#        else:
#            print "Non-OVAL checking system found: " + check.get("system")
    return ovalfiles


def main():
    if len(sys.argv) < 3:
        print "Provide an XCCDF file and an ID name scheme."
        print "This script finds check-content files (currently, OVAL) referenced from XCCDF and synchronizes all IDs."
        sys.exit(1)

    xccdffile = sys.argv[1]
    idname = sys.argv[2]

    os.chdir("./output")
    # step over xccdf file, and find referenced oval files
    xccdftree = parse_xml_file(xccdffile)

    checks = xccdftree.findall(".//{%s}check" % xccdf_ns)
    ovalfiles = get_ovalfiles(checks)

    if len(ovalfiles) > 1:
        sys.exit("referencing more than one OVAL file is not yet supported by this script.")
    ovalfile = ovalfiles.pop()

    # rename all IDs in the oval file
    ovaltree = parse_xml_file(ovalfile) 
    translator = idtranslate.idtranslator(idname+".ini", "oval:"+idname)
    ovaltree = translator.translate(ovaltree, store_defname=True, refsource="scap-security-guide")

    newovalfile = ovalfile.replace(".xml", "-" + idname + ".xml")
    ET.ElementTree(ovaltree).write(newovalfile)

    # rename all IDs and file refs in the xccdf file
    for check in checks:
        checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
        if checkcontentref is None:
            continue
        checkid = translator.assign_id("definition", checkcontentref.get("name"))
        checkcontentref.set("name", checkid)
        checkcontentref.set("href", newovalfile)

        checkexport = check.find("./{%s}check-export" % xccdf_ns)
        if checkexport is not None:
            newexportname = translator.assign_id("variable", checkexport.get("export-name"))
            checkexport.set("export-name", newexportname) 

    newxccdffile = xccdffile.replace(".xml", "-" + idname + ".xml")
    #ET.dump(xccdftree)
    ET.ElementTree(xccdftree).write(newxccdffile)
    sys.exit(0)

if __name__ == "__main__":
    main()

