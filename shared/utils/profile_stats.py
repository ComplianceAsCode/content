#!/usr/bin/python

import lxml.etree as ET
import optparse
import sys

script_usage = """
%prog -b XCCDF_file [-p XCCDF_profile] [--full-stats]

Obtains and displays XCCDF profile statistics like:
* Count of rules present in the <xccdf:Profile>
* Count of rules having OVAL implemented [% of completion]
* Count of rules having remediation implemented [% of completion]

for the XCCDF benchmark provided as -b or --benchmark argument.

Unless -p or --profile option was provided, it will display statistics
for all profiles found in the benchmark. Use -p or --profile XCCDF_profile
to obtain statistics solely for particular profile.

If --full-stats option was provided it will also display the IDs
of unimplemented OVAL checks, remediation scripts, and IDs of rules
not having CCE identifier assigned yet.

NOTE: Does NOT work on DataStream benchmark format (yet)!
"""


xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
rem_system = "urn:xccdf:fix:script:sh"
cce_system = "https://nvd.nist.gov/cce/index.cfm"
console_width = 80


class RuleStats(object):
    def __init__(self, rid=None, roval=None, rfix=None, rcce=None):
        self.dict = {'id': rid,
                     'oval': roval,
                     'fix': rfix,
                     'cce': rcce}


class XCCDFBenchmark(object):
    def __init__(self, filepath):
        self.tree = None
        self.stats = []
        try:
            with open(filepath, 'r') as xccdf_file:
                file_string = xccdf_file.read()
                tree = ET.fromstring(file_string)
                self.tree = tree
        except IOError as ioerr:
            print("%s" % ioerr)
            sys.exit(1)

    def get_profile_stats(self, profile=None, full_stats=False):
        """Obtain statistics for the profile"""

        xccdf_profile = self.tree.find("./{%s}Profile[@id=\"%s\"]" %
                                       (xccdf_ns, profile))
        if xccdf_profile is None:
            print("No such profile \"%s\" found in the benchmark!" % profile)
            print("* Available profiles:")
            profiles_avail = self.tree.findall("./{%s}Profile" % (xccdf_ns))
            for profile in profiles_avail:
                print("** %s" % profile.get('id'))
            sys.exit(1)

        rules = xccdf_profile.findall("./{%s}select[@selected=\"true\"]" %
                                      xccdf_ns)
        for rule in rules:
            rule_id = rule.get('idref')
            xccdf_rule = self.tree.find(".//{%s}Rule[@id=\"%s\"]" %
                                        (xccdf_ns, rule_id))
            if xccdf_rule is not None:
                oval = xccdf_rule.find("./{%s}check[@system=\"%s\"]" %
                                       (xccdf_ns, oval_ns))
                fix = xccdf_rule.find("./{%s}fix[@system=\"%s\"]" %
                                      (xccdf_ns, rem_system))
                cce = xccdf_rule.find("./{%s}ident[@system=\"%s\"]" %
                                      (xccdf_ns, cce_system))
                self.stats.append(RuleStats(rule_id, oval, fix, cce))

    def show_profile_stats(self, profile=None, full_stats=False):
        """Displays statistics for specific profile"""

        self.get_profile_stats(profile, full_stats)
        print("* Statistics of '%s' profile:" % profile)
        rules_count = len(self.stats)
        print("** Count of rules: %d" % rules_count)
        ovals_count = len([x for x in self.stats
                           if x.dict['oval'] is not None])
        print("** Count of ovals: %d [%d%% complete]" %
              (ovals_count, float(ovals_count) / rules_count * 100))
        fixes_count = len([x for x in self.stats if x.dict['fix'] is not None])
        print("** Count of fixes: %d [%d%% complete]" %
              (fixes_count, float(fixes_count) / rules_count * 100))
        if full_stats:
            missing_ovals = [x.dict['id'] for x in self.stats
                             if x.dict['oval'] is None]
            if missing_ovals:
                print("** Rules of '%s' profile missing OVAL:" % profile)
                self.console_print(missing_ovals, console_width)
            else:
                print("** All rules of '%s' " % profile + "profile have " +
                      "OVAL implemented.")
            missing_fixes = [x.dict['id'] for x in self.stats
                             if x.dict['fix'] is None]
            if missing_fixes:
                print("** Rules of '%s' profile missing remediation:" %
                      profile)
                self.console_print(missing_fixes, console_width)
            else:
                print("** All rules of '%s' " % profile + "profile have " +
                      "remediation implemented.")
            missing_cces = [x.dict['id'] for x in self.stats
                            if x.dict['cce'] is None]
            if missing_cces:
                print("** Rules of '%s' profile missing CCE identifier:" %
                      profile)
                self.console_print(missing_cces, console_width)
            else:
                print("** All rules of '%s' " % profile + "profile have " +
                      "CCE identifier assigned.")
        print("\n")
        self.stats = []

    def console_print(self, content, width):
        """Prints the 'content' array left aligned, each time 45 characters
           long, each row 'width' characters wide"""

        msg = ''
        for x in content:
            if len(msg) + len(x) < width - 6:
                msg += '   ' + "%-45s" % x
            else:
                print("%s" % msg)
                msg = '   ' + "%-45s" % x
        if msg != '':
            print("%s" % msg)


def parse_options():
    parser = optparse.OptionParser(usage=script_usage, version="%prog 1.0")
    parser.add_option("-p", "--profile", default=False,
                      action="store", dest="profile",
                      help="Show statistics for this XCCDF Profile only")
    parser.add_option("-b", "--benchmark", default=False,
                      action="store", dest="benchmark_file",
                      help="Specify XCCDF benchmark to act on")
    parser.add_option("--full-stats", default=False,
                      action="store_true", dest="full_stats",
                      help="Show advanced statistics (missing OVALs, "
                      "remediations, and CCE identifiers)")

    (options, args) = parser.parse_args()
    if not options.benchmark_file:
        print("Missing XCCDF location via -b or --benchmark arguments!\n")
        parser.print_help()
        sys.exit(1)

    return (options, args)


def main():
    (options, args) = parse_options()

    benchmark = XCCDFBenchmark(options.benchmark_file)
    if options.profile:
        benchmark.show_profile_stats(options.profile, options.full_stats)
    else:
        all_profile_elems = benchmark.tree.findall("./{%s}Profile" %
                                                   (xccdf_ns))
        for elem in all_profile_elems:
            profile = elem.get('id')
            if profile is not None:
                benchmark.show_profile_stats(profile, options.full_stats)

if __name__ == '__main__':
    main()
