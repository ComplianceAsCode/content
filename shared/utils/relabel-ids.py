#!/usr/bin/python

import re
import sys
import os
import lxml.etree as ET

try:
    from configparser import SafeConfigParser
except ImportError:
    # for python2
    from ConfigParser import SafeConfigParser

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
import idtranslate_module as idtranslate

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
cce_uri = "http://cce.mitre.org"


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


def create_xccdf_id_to_cce_id_mapping(xccdftree):
    #
    # Create dictionary having form of
    #
    # 'XCCDF ID' : 'CCE ID'
    #
    # for each XCCDF rule having <ident system='http://cce.mitre.org'>CCE-ID</ident>
    # element set in the XCCDF document
    xccdftocce_idmapping = {}

    xccdfrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    for rule in xccdfrules:
        xccdfid = rule.get("id")
        if xccdfid is not None:
            identcce = rule.find("./{%s}ident[@system='http://cce.mitre.org']" % xccdf_ns)
            if identcce is not None:
                cceid = identcce.text
                xccdftocce_idmapping[xccdfid] = cceid

    return xccdftocce_idmapping


def add_cce_id_refs_to_oval_checks(ovaltree, idmappingdict):
    #
    # For each XCCDF rule ID having <ident> CCE set and
    # having OVAL check implemented (remote OVAL isn't sufficient!)
    # add a new <reference> element into the OVAL definition having the
    # following form:
    #
    # <reference source="CCE" ref_id="CCE-ID" />
    #
    # where "CCE-ID" is the CCE identifier for that particular rule
    # retrieved from the XCCDF file
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1092
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1230
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1229
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1228

    ovalrules = ovaltree.findall(".//{%s}definition" % oval_ns)
    for rule in ovalrules:
        ovalid = rule.get("id")
        ovaldesc = rule.find(".//{%s}description" % oval_ns)
        # Assign <reference> CCE elements only to those OVAL checks whose
        # XCCDF rule ID has <ident> CCE set
        if ovalid is not None and \
           ovaldesc is not None and \
           ovalid in idmappingdict:
            xccdfcceid = idmappingdict[ovalid]
            # IF CCE ID IS IN VALID FORM (either 'CCE-XXXX-X' or 'CCE-XXXXX-X'
            # where each X is a digit, and the final X is a check-digit)
            if re.search(r'CCE-\d{4,5}-\d', xccdfcceid) is not None:
                # Then append the <reference source="CCE" ref_id="CCE-ID" /> element right
                # after <description> element of specific OVAL check
                ccerefelem = ET.Element('reference', ref_id="%s" % xccdfcceid, source="CCE")
                ovaldesc.addnext(ccerefelem)
                # Sanity check if appending succeeded
                if ccerefelem.getprevious() is not ovaldesc:
                    sys.stderr.write("ERROR: Failed to add CCE ID to %s. "
                                     "Exiting" % (ovalid))
                    sys.exit(1)


def ensure_by_xccdf_referenced_oval_def_is_defined_in_oval_file(xccdftree, ovaltree):
    # Ensure all OVAL checks referenced by XCCDF are implemented in OVAL file
    # Drop the reference from XCCDF to OVAL definition if:
    # * Particular OVAL definition isn't present in OVAL file,
    # * That OVAL definition doesn't constitute a remote OVAL
    #   (@href of <check-content-ref> doesn't start with 'http'
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1092
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1095
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1098

    for rule in xccdftree.findall(".//{%s}Rule" % xccdf_ns):
        xccdfid = rule.get("id")
        if xccdfid is None:
            # TODO: We probably should issue a warning here or even error..
            continue

        # Search OVAL ID in OVAL document
        ovalid = ovaltree.find(".//{%s}definition[@id=\"%s\"]" % (oval_ns, xccdfid))
        if ovalid is not None:
            # The OVAL check was found, we can continue
            continue

        # Search same ID in XCCDF document
        check = rule.find(".//{%s}check[@system=\"%s\"]" % (xccdf_ns, oval_ns))
        if check is None:
            # Skip XCCDF rules not referencing OVAL checks
            continue

        checkcontentref = check.find(".//{%s}check-content-ref" % xccdf_ns)
        if checkcontentref is None:
            continue

        try:
            checkcontentref_hrefattr = checkcontentref.get('href')
        except KeyError:
            # @href attribute of <check-content-ref> is required by XCCDF standard
            sys.stderr.write("ERROR: Invalid OVAL <check-content-ref> detected!"
                             " Exiting..\n")
            sys.exit(1)

        # Skip remote OVAL (should cover both 'http://' and 'https://' cases)
        if checkcontentref_hrefattr.startswith('http'):
            continue

        # For local OVAL drop the reference to OVAL definition from XCCDF document
        # in the case:
        # * OVAL definition is referenced from XCCDF file,
        # * But not defined in OVAL file
        sys.stderr.write("WARNING: OVAL check '%s' was not found, removing "
                         "<check-content> element from the XCCDF rule.\n"
                         % xccdfid)
        rule.remove(check)


def check_and_correct_xccdf_to_oval_data_export_matching_constraints(xccdftree, ovaltree):
        # Verify if <xccdf:Value> 'type' to corresponding OVAL variable 'datatype' export matching constraint:
        #
        # http://csrc.nist.gov/publications/nistpubs/800-126-rev2/SP800-126r2.pdf#page=30&zoom=auto,69,313
        #
        # is met. Also correct the 'type' attribute of those <xccdf:Value> elements where necessary in
        # order the produced content to meet this constraint.
        #
        # To correct the constraint we use simpler approach - prefer to fix 'type' attribute of <xccdf:Value>
        # rather than 'datatype' attribute of the corresponding OVAL variable since there might be additional
        # OVAL variables, derived from the affected OVAL variable, and in that case we would need to fix the
        # 'datatype' attribute in each of them.
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1089


        # Define the <xccdf:Value> 'type' to OVAL variable 'datatype' export matching constraints mapping
        # as specified in Table 16 of XCCDF v1.2 standard:
        # http://csrc.nist.gov/publications/nistpubs/800-126-rev2/SP800-126r2.pdf#page=30&zoom=auto,69,313
        #
        oval_to_xccdf_datatype_constraints = {
            'int' : 'number',
            'float' : 'number',
            'boolean' : 'boolean',
            'string' : 'string',
            'evr_string' : 'string',
            'version' : 'string',
            'ios_version' : 'string',
            'fileset_revision' : 'string',
            'binary' :  'string'
        }

        # Loop through all <external_variables> in the OVAL document
        ovalextvars = ovaltree.findall(".//{%s}external_variable" % oval_ns)
        if ovalextvars is not None:
            for ovalextvar in ovalextvars:
                # Verify the found external variable has both 'id' and 'datatype' set
                if 'id' not in ovalextvar.attrib or 'datatype' not in ovalextvar.attrib:
                    sys.stderr.write("ERROR: Invalid OVAL <external_variable> "
                                     "found. Exiting\n")
                    sys.exit(1)
                # Obtain the 'id' and 'datatype attribute values
                if 'id' in ovalextvar.attrib and 'datatype' in ovalextvar.attrib:
                    ovalvarid = ovalextvar.get('id')
                    ovalvartype = ovalextvar.get('datatype')

                # Locate the corresponding <xccdf:Value> with the same ID in the XCCDF
                xccdfvar = xccdftree.find(".//{%s}Value[@id=\"%s\"]" % (xccdf_ns, ovalvarid))
                if xccdfvar is not None:
                    # Verify the found value has 'type' attribute set
                    if 'type' not in xccdfvar.attrib:
                        sys.stderr.write("ERROR: Invalid XCCDF variable found. "
                                         "Exiting\n")
                        sys.exit(1)
                    else:
                        xccdfvartype = xccdfvar.get('type')
                        # This is the required XCCDF 'type' for <xccdf:Value> derived
                        # from OVAL variable 'datatype' and mapping above
                        reqxccdftype = oval_to_xccdf_datatype_constraints[ovalvartype]
                        # Compare the actual value of 'type' of <xccdf:Value> with the requirement
                        if xccdfvartype != reqxccdftype:
                            # If discrepancy is found, issue a warning
                            sys.stderr.write(
                                "Warning: XCCDF 'type' of \"%s\" value does "
                                "not meet the XCCDF value 'type' to OVAL "
                                "variable 'datatype' export matching "
                                "constraint! Got: \"%s\", Expected: \"%s\". "
                                "Resetting it! Set 'type' of \"%s\" "
                                "<xccdf:value> to '%s' directly in the XCCDF "
                                "content to dismiss this warning!" %
                                (ovalvarid, xccdfvartype, reqxccdftype,
                                 ovalvarid, reqxccdftype)
                            )
                            # And reset the 'type' attribute of such a <xccdf:Value> to the required type
                            xccdfvar.attrib['type'] = reqxccdftype


def verify_correct_form_of_referenced_cce_identifiers(xccdftree):
    # Correct CCE identifiers have the form of
    # * either CCE-XXXX-X,
    # * or CCE-XXXXX-X
    # where each X is a digit, and the final X is a check-digit
    # based on http://people.redhat.com/swells/nist-scap-validation/scap-val-requirements-1.2.html Requirement A17
    #
    # But in SSG benchmarks the CCEs till unassigned have the form of e.g. "RHEL7-CCE-TBD"
    # (or any other format possibly not matching the above two requirements)
    #
    # If this is the case for specific SSG product, drop such CCE identifiers from the XCCDF
    # since they are in invalid format!
    #
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1230
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1229
    # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1228

    xccdfrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    for rule in xccdfrules:
        identcce = rule.find(".//{%s}ident[@system=\"%s\"]" % (xccdf_ns, cce_uri))
        if identcce is not None:
            cceid = identcce.text
            # Found CCE identifier doesn't have one of the allowed forms listed above
            if re.search(r'CCE-\d{4,5}-\d', cceid) is None:
                # Drop such <xccdf:ident> CCE element from the XCCDF in that case
                identcce.getparent().remove(identcce)


def main():
    if len(sys.argv) < 3:
        sys.stderr.write("Provide an XCCDF file and an ID name scheme.\n")
        sys.stderr.write("This script finds check-content files (currently, "
                         "OVAL and OCIL) referenced from XCCDF and "
                         "synchronizes all IDs.\n")
        sys.exit(1)

    xccdffile = sys.argv[1]
    idname = sys.argv[2]

    # Step over xccdf file, and find referenced check files
    xccdftree = parse_xml_file(xccdffile)

    # Create XCCDF rule ID to assigned CCE ID mapping
    xccdf_to_cce_id_mapping = create_xccdf_id_to_cce_id_mapping(xccdftree)

    # Check that OVAL IDs and XCCDF Rule IDs match
    if 'unlinked-ocilref' not in xccdffile:
        allrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
        for rule in allrules:
            xccdf_rule = rule.get("id")
            if xccdf_rule is not None:
                checks = rule.find("./{%s}check" % xccdf_ns)
                if checks is not None:
                    for check in checks:
                        check_name = check.get("name")
                        # Verify match of XCCDF vs OVAL / OCIL IDs for
                        # * the case of OVAL <check>
                        # * the case of OCIL <check>
                        if (not xccdf_rule == check_name and check_name is not None \
                            and not xccdf_rule + '_ocil' == check_name \
                            and not xccdf_rule == 'sample_rule'):
                            sys.stderr.write("The OVAL / OCIL ID does not "
                                             "match the XCCDF Rule ID!\n")
                            if '_ocil' in check_name:
                                sys.stderr.write("  OCIL ID:       \'%s\'\n"
                                                 % (check_name))
                            else:
                                sys.stderr.write("  OVAL ID:       \'%s\'\n"
                                                 % (check_name))
                            sys.stderr.write("  XCCDF Rule ID: \'%s\'\n"
                                             % (xccdf_rule))
                            sys.stderr.write("Both OVAL/OCIL and XCCDF Rule "
                                             "IDs must match!" % (xccdf_rule))
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

    # Rename all IDs in the oval file
    if ovalfile:
        ovaltree = parse_xml_file(ovalfile)

        # Add new <reference source="CCE" ref_id="CCE-ID" /> element to those OVAL
        # checks having CCE ID already assigned in XCCDF for particular rule.
        # But add the <reference> only in the case CCE is in valid form!
        # Exit with failure if the assignment wasn't successful
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1092
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1230
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1229
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1228
        add_cce_id_refs_to_oval_checks(ovaltree, xccdf_to_cce_id_mapping)

        # Verify all by XCCDF referenced (local) OVAL checks are defined in OVAL file
        # If not drop the <check-content> OVAL checksystem reference from XCCDF
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1092
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1095
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1098
        ensure_by_xccdf_referenced_oval_def_is_defined_in_oval_file(xccdftree, ovaltree)

        # Verify the XCCDF to OVAL datatype export matching constraints
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1089
        check_and_correct_xccdf_to_oval_data_export_matching_constraints(xccdftree, ovaltree)

        # Verify if CCE identifiers present in the XCCDF follow the required form
        # (either CCE-XXXX-X, or CCE-XXXXX-X). Drop from XCCDF those who don't follow it
        verify_correct_form_of_referenced_cce_identifiers(xccdftree)

        ovaltree = translator.translate(ovaltree, store_defname=True)
        newovalfile = ovalfile.replace("unlinked", "linked")
        ET.ElementTree(ovaltree).write(newovalfile)

    # Rename all IDs in the ocil file
    if ocilfile:
        ociltree = parse_xml_file(ocilfile)
        ociltree = translator.translate(ociltree)
        newocilfile = ocilfile.replace("unlinked", "linked")
        ET.ElementTree(ociltree).write(newocilfile)

    # Rename all IDs and file refs in the xccdf file
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

    newxccdffile = xccdffile.replace("unlinked", "linked")
    # ET.dump(xccdftree)
    ET.ElementTree(xccdftree).write(newxccdffile)
    sys.exit(0)

if __name__ == "__main__":
    main()
