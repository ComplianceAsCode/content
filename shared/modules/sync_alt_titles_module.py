#!/usr/bin/python2

import sys
import optparse
import lxml.etree as ET

#
# This script is designed to synchronize an alternative-titles file,
# which allows for specifying (and later inserting) titles of an alternate
# format into the main body of XCCDF content.
#
# It requires three arguments: an XCCDF file with Rules (which already have
# titles), a profile name (that specifies the Rules for which to populate the
# alternative-titles file), and the name of the alternative-titles file.
#

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"


def parse_options():
    usage = "usage: %prog -p profile -f titlesfile xccdf_file"
    parser = optparse.OptionParser(usage=usage, version="%prog ")
    # only some options are on by default
    parser.add_option("-p", "--profile", default=False,
                      action="store", dest="profile_name",
                      help="provide title-holders for Rules in this XCCDF Profile")
    parser.add_option("-f", "--titles-file", default=False,
                      action="store", dest="titlesfile",
                      help="an alternate titles file, in which to populate title-holders")
    parser.add_option("-r", "--read-only", default=False,
                      action="store_true", dest="readonly",
                      help="print changes that would be made, but do not make them")
    (options, args) = parser.parse_args()
    if len(args) < 1 or not options.profile_name or not options.titlesfile:
        parser.print_help()
        sys.exit(1)
    return (options, args)


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
    (options, args) = parse_options()
    xccdffilename = args[0]

    # extract all of the rules within the xccdf
    xccdftree = ET.parse(xccdffilename)
    rules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    profile_ruleids = get_profileruleids(xccdftree, options.profile_name)
    prunedrules = rules[:]
    for rule in rules:
        if rule.get("id") not in profile_ruleids:
            prunedrules.remove(rule)
    rules = prunedrules

    titlestree = ET.parse(options.titlesfile)
    alttitles = titlestree.findall(".//{%s}title" % xccdf_ns)
    alttitles_rulerefs = [alttitle.get("rule") for alttitle in alttitles]

    for rule in rules:
        ruleid = rule.get("id")
        if ruleid not in alttitles_ruleref:
            titleholder = ET.SubElement(titlestree.getroot(), "title")
            titleholder.text = "\n"
        else:
            titleholder = titlestree.find("./{"+xccdf_ns+"}title[@rule='"+ruleid+"']")
        titleholder.attrib['rule'] = rule.get("id")
        shorttitle = rule.find("./{%s}title" % xccdf_ns)
        titleholder.attrib['shorttitle'] = shorttitle.text

    titlestree.write(options.titlesfile, pretty_print=True)

    sys.exit(0)

if __name__ == "__main__":
    main()
