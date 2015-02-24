#!/usr/bin/python

import sys
import optparse
import lxml.etree as ET

#
# This script can verify consistency of references (linkage) between XCCDF and
# OVAL, and also search based on other criteria such as existence of policy
# references in XCCDF.
#
# It must be run from the same directory as the XCCDF and OVAL content
# it references.

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"

# we use these strings to look for references within the XCCDF rules
nist_ref_href = "http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf"
disa_ref_href = "http://iase.disa.mil/stigs/cci/Pages/index.aspx"

# default exit value - success
exit_value = 0


def parse_options():
    usage = "usage: %prog [options] xccdf_file"
    parser = optparse.OptionParser(usage=usage, version="%prog ")
    # only some options are on by default
    parser.add_option("-p", "--profile", default=False,
                      action="store", dest="profile_name",
                      help="act on Rules from this XCCDF Profile only")
    parser.add_option("--rules-with-invalid-checks", default=False,
                      action="store_true", dest="rules_with_invalid_checks",
                      help="print XCCDF Rules that reference an invalid/nonexistent check")
    parser.add_option("--rules-without-checks", default=False,
                      action="store_true", dest="rules_without_checks",
                      help="print XCCDF Rules that do not include a check")
    parser.add_option("--rules-without-severity", default=False,
                      action="store_true", dest="rules_without_severity",
                      help="print XCCDF Rules that do not include a severity")
    parser.add_option("--rules-without-nistrefs", default=False,
                      action="store_true", dest="rules_without_nistrefs",
                      help="print XCCDF Rules which do not include any NIST 800-53 references")
    parser.add_option("--rules-without-disarefs", default=False,
                      action="store_true", dest="rules_without_disarefs",
                      help="print XCCDF Rules which do not include any DISA CCI references")
    parser.add_option("--rules-with-nistrefs-outside-profile", default=False,
                      action="store_true", dest="nistrefs_not_in_profile",
                      help="print XCCDF Rules which have a NIST reference, but are not part of the Profile specified")
    parser.add_option("--rules-with-disarefs-outside-profile", default=False,
                      action="store_true", dest="disarefs_not_in_profile",
                      help="print XCCDF Rules which have a DISA CCI reference, but are not part of the Profile specified")
    parser.add_option("--ovaldefs-unused", default=False,
                      action="store_true", dest="ovaldefs_unused",
                      help="print OVAL definitions which are not used by any XCCDF Rule")
    parser.add_option("--all-checks", default=False, action="store_true",
                      dest="all_checks",
                      help="perform all checks on the given XCCDF file")
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.print_help()
        sys.exit(1)
    return (options, args)


def get_ovalfiles(checks):
    global exit_value
    # iterate over all checks, grab the OVAL files referenced within
    ovalfiles = set()
    for check in checks:
        if check.get("system") == oval_ns:
            checkcontentref = check.find("./{%s}check-content-ref" % xccdf_ns)
            ovalfiles.add(checkcontentref.get("href"))
        elif check.get("system") != "ocil-transitional":
            print "Non-OVAL checking system found: " + check.get("system")
            exit_value = 1
    return ovalfiles


def get_profileruleids(xccdftree, profile_name):
    ruleids = []

    while profile_name:
        profile = xccdftree.find(".//{%s}Profile[@id='%s']"
                                 % (xccdf_ns, profile_name))
        if profile is None:
            sys.exit("Specified XCCDF Profile %s was not found.")
        for select in profile.findall(".//{%s}select" % xccdf_ns):
            ruleids.append(select.get("idref"))
        profile_name = profile.get("extends")

    return ruleids


def main():
    global exit_value
    (options, args) = parse_options()
    xccdffilename = args[0]

    # extract all of the rules within the xccdf
    xccdftree = ET.parse(xccdffilename)
    rules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)

    # if a profile was specified, get rid of any Rules that aren't in it
    if options.profile_name:
        profile_ruleids = get_profileruleids(xccdftree, options.profile_name)
        prunedrules = rules[:]
        for rule in rules:
            if rule.get("id") not in profile_ruleids:
                prunedrules.remove(rule)
        rules = prunedrules

    # step over xccdf file, and find referenced oval files
    checks = xccdftree.findall(".//{%s}check" % xccdf_ns)
    ovalfiles = get_ovalfiles(checks)

    # this script only supports the inclusion of one OVAL file
    if len(ovalfiles) > 1:
        sys.exit("Referencing more than one OVAL file is not yet " +
                 "supported by this script.")

    # find important elements within the XCCDF and the OVAL
    ovalfile = ovalfiles.pop()
    ovaltree = ET.parse(ovalfile)
    # collect all compliance checks (not inventory checks, which are
    # needed by CPE)
    ovaldefs = ovaltree.findall(".//{%s}definition[@class='compliance']"
                                % oval_ns)
    ovaldef_ids = [ovaldef.get("id") for ovaldef in ovaldefs]

    oval_extenddefs = ovaltree.findall(".//{%s}extend_definition" % oval_ns)
    ovaldef_ids_extended = [oval_extenddef.get("definition_ref") for oval_extenddef in oval_extenddefs]
    ovaldef_ids_extended = list(set(ovaldef_ids_extended))

    check_content_refs = xccdftree.findall(".//{%s}check-content-ref"
                                           % xccdf_ns)

    # now we can actually do the verification work here
    if options.rules_with_invalid_checks or options.all_checks:
        for check_content_ref in check_content_refs:
            refname = check_content_ref.get("name")
            if refname not in ovaldef_ids:
                rule = check_content_ref.getparent().getparent()
                print ("Invalid OVAL definition referenced by XCCDF Rule: " +
                       rule.get("id"))
                exit_value = 1

    if options.rules_without_checks or options.all_checks:
        for rule in rules:
            check = rule.find("./{%s}check" % xccdf_ns)
            if check is None:
                print ("No reference to OVAL definition in XCCDF Rule: " +
                       rule.get("id"))
                exit_value = 1

    if options.rules_without_severity or options.all_checks:
        for rule in rules:
            if rule.get("severity") is None:
                print "No severity assigned to XCCDF Rule: " + rule.get("id")
                exit_value = 1

    if options.rules_without_nistrefs or options.rules_without_disarefs or options.all_checks:
        for rule in rules:
            # find all references in the current rule
            refs = rule.findall(".//{%s}reference" % xccdf_ns)
            if refs is None:
                print "No reference assigned to XCCDF Rule: " + rule.get("id")
                exit_value = 1
            else:
                # loop through the Rule's references and put their hrefs
                # in a list
                ref_href_list = [ref.get("href") for ref in refs]
                # print warning if rule does not have a NIST reference
                if (not nist_ref_href in ref_href_list) and options.rules_without_nistrefs:
                    print ("No valid NIST reference in XCCDF Rule: " +
                           rule.get("id"))
                    exit_value = 1
                # print warning if rule does not have a DISA reference
                if (not disa_ref_href in ref_href_list) and options.rules_without_disarefs:
                    print ("No valid DISA CCI reference in XCCDF Rule: " +
                           rule.get("id"))
                    exit_value = 1

    if options.disarefs_not_in_profile or options.nistrefs_not_in_profile:
        if options.profile_name is None:
            sys.exit("The options for finding Rules with a reference, "
                     "but which are not in a Profile, requires specifying a Profile.")
        allrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
        for rule in allrules:
            # find all references in the current rule
            refs = rule.findall(".//{%s}reference" % xccdf_ns)
            ref_href_list = [ref.get("href") for ref in refs]
            # print warning if Rule is outside Profile and has a NIST reference
            if options.nistrefs_not_in_profile:
                if (nist_ref_href in ref_href_list) and (rule.get("id") not in profile_ruleids):
                    print ("XCCDF Rule found with NIST reference outside Profile %s: "
                           % options.profile_name + rule.get("id"))
                    exit_value = 1
            # print warning if Rule is outside Profile and has a DISA reference
            if options.disarefs_not_in_profile:
                if (disa_ref_href in ref_href_list) and (rule.get("id") not in profile_ruleids):
                    print ("XCCDF Rule found with DISA CCI reference outside Profile %s: "
                           % options.profile_name + rule.get("id"))
                    exit_value = 1

    if options.ovaldefs_unused or options.all_checks:
        # create a list of all of the OVAL compliance check ids that are
        # defined in the oval file
        oval_checks_list = [ovaldef.get("id") for ovaldef in ovaldefs]
        # now loop through the xccdf rules; if a rule references an oval check
        # we remove the oval check from our list
        for check_content in check_content_refs:
            # remove from the list
            if check_content.get("name") in oval_checks_list:
                oval_checks_list.remove(check_content.get("name"))
        # the list should now contain the OVAL checks that are not referenced
        # by any XCCDF rule
        oval_checks_list.sort()
        for oval_id in oval_checks_list:
            # don't print out the OVAL defs that are extended by others,
            # as they're not unused
            if oval_id not in ovaldef_ids_extended:
                print "OVAL Check is not referenced by XCCDF: %s" % oval_id
                exit_value = 1

    sys.exit(exit_value)

if __name__ == "__main__":
    main()
