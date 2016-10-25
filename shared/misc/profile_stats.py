#!/usr/bin/python

import json
import lxml.etree as ET
import optparse
import sys

script_usage = """
%prog -b XCCDF_file [-p XCCDF_profile] [--implemented] [--missing] [--all]
                    [--implemented-ovals] [--implemented-fixes] [--assigned-cces]
                    [--missing-ovals] [--missing-fixes] [--missing-cces] [--json]

Obtains and displays XCCDF profile statistics like:
* Count of rules present in the <xccdf:Profile>
* Count of rules having OVAL implemented [% of completion]
* Count of rules having remediation implemented [% of completion]

for the XCCDF benchmark provided as -b or --benchmark argument.

Unless -p or --profile option was provided, it will display statistics
for all profiles found in the benchmark. Use -p or --profile XCCDF_profile
to obtain statistics solely for particular profile.

If --implemented option was provided it will also display the IDs
of implemented OVAL checks, remediation scripts, and IDs of rules
having CCE identifier already assigned. It is a shortcut for combination
of --implemented-ovals, --implemented-fixes, and --assigned-cces options.

If --missing option was provided it will also display the IDs of
not implemented OVAL checks, remediation scripts, and IDs of rules
not having CCE identifier assigned yet. It is a shortcut for combination
of --missing-ovals, --missing-fixes, and --missing-cces options.

If --all option was provided, it will display all available information.
It is a shortcut for combination of --implemented and --missing options.

If --json option is provided, it will display the statistics in the form
of json format file (rather than default text form)

NOTE: Does NOT work on DataStream benchmark format (yet)!
"""


xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
rem_system = "urn:xccdf:fix:script:sh"
cce_system = "https://nvd.nist.gov/cce/index.cfm"
ssg_version_uri = "https://github.com/OpenSCAP/scap-security-guide/releases/latest"
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
        try:
            with open(filepath, 'r') as xccdf_file:
                file_string = xccdf_file.read()
                tree = ET.fromstring(file_string)
                self.tree = tree
        except IOError as ioerr:
            print("%s" % ioerr)
            sys.exit(1)

    def get_profile_stats(self, profile = None):
        """Obtain statistics for the profile"""

        # Holds the intermediary statistics for profile
        profile_stats = { 'profile_id' : None,
                          'ssg_version' : 0,
                          'rules_count' : 0,
                          'implemented_ovals' : [],
                          'implemented_ovals_pct' : 0,
                          'missing_ovals' : [],
                          'implemented_fixes' : [],
                          'implemented_fixes_pct' : 0,
                          'missing_fixes' : [],
                          'assigned_cces' : [],
                          'assigned_cces_pct' : 0,
                          'missing_cces' : []
                         }

        rule_stats = []
        ssg_version_elem = self.tree.find("./{%s}version[@update=\"%s\"]" %
                                          (xccdf_ns, ssg_version_uri))
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
                rule_stats.append(RuleStats(rule_id, oval, fix, cce))

        if not rule_stats:
            print('Unable to retrieve statistics for %s profile' % profile)
            sys.exit(1)

        profile_stats['profile_id'] = profile
        if ssg_version_elem is not None:
            profile_stats['ssg_version'] = \
                'SCAP Security Guide %s' % ssg_version_elem.text
        profile_stats['rules_count'] = len(rule_stats)
        profile_stats['implemented_ovals'] = \
            [x.dict['id'] for x in rule_stats if x.dict['oval'] is not None]
        profile_stats['implemented_ovals_pct'] = \
            float(len(profile_stats['implemented_ovals'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_ovals'] = \
            [x.dict['id'] for x in rule_stats if x.dict['oval'] is None]
        profile_stats['implemented_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['fix'] is not None]
        profile_stats['implemented_fixes_pct'] = \
            float(len(profile_stats['implemented_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['fix'] is None]
        profile_stats['assigned_cces'] = \
            [x.dict['id'] for x in rule_stats if x.dict['cce'] is not None]
        profile_stats['assigned_cces_pct'] = \
            float(len(profile_stats['assigned_cces'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_cces'] = \
            [x.dict['id'] for x in rule_stats if x.dict['cce'] is None]

        return profile_stats

    def show_profile_stats(self, profile, options):
        """Displays statistics for specific profile"""

        profile_stats = self.get_profile_stats(profile)
        rules_count = profile_stats['rules_count']
        impl_ovals_count = len(profile_stats['implemented_ovals'])
        impl_fixes_count = len(profile_stats['implemented_fixes'])
        impl_cces_count = len(profile_stats['assigned_cces'])

        if not options.json:
            print("\n* %s statistics of '%s' profile:" %
                  (profile_stats['ssg_version'], profile))
            print("** Count of rules: %d" % rules_count)
            print("** Count of ovals: %d [%d%% complete]" %
                  (impl_ovals_count, \
                  profile_stats['implemented_ovals_pct']))
            print("** Count of fixes: %d [%d%% complete]" %
                  (impl_fixes_count, \
                  profile_stats['implemented_fixes_pct']))
            print("** Count of CCEs: %d [%d%% complete]" %
                  (impl_cces_count, \
                  profile_stats['assigned_cces_pct']))

            if options.implemented_ovals and \
               profile_stats['implemented_ovals']:
                print("*** Rules of '%s' " % profile +
                      "profile having OVAL check: %d of %d [%d%% complete]" %
                      (impl_ovals_count, rules_count,
                      profile_stats['implemented_ovals_pct']))
                self.console_print(profile_stats['implemented_ovals'],
                                   console_width)

            if options.implemented_fixes and \
               profile_stats['implemented_fixes']:
                print("*** Rules of '%s' " % profile + "profile having " +
                      "remediation script: %d of %d [%d%% complete]" %
                      (impl_fixes_count, rules_count,
                      profile_stats['implemented_fixes_pct']))
                self.console_print(profile_stats['implemented_fixes'],
                                   console_width)

            if options.assigned_cces and \
               profile_stats['assigned_cces']:
                print("*** Rules of '%s' " % profile +
                      "profile having CCE assigned: %d of %d [%d%% complete]" %
                      (impl_cces_count, rules_count,
                      profile_stats['assigned_cces_pct']))
                self.console_print(profile_stats['assigned_cces'],
                                   console_width)

            if options.missing_ovals and profile_stats['missing_ovals']:
                print("*** Rules of '%s' " % profile + "profile missing " +
                      "OVAL: %d of %d [%d%% complete]" %
                      (rules_count - impl_ovals_count, rules_count,
                      profile_stats['implemented_ovals_pct']))
                self.console_print(profile_stats['missing_ovals'],
                                   console_width)

            if options.missing_fixes and profile_stats['missing_fixes']:
                print("*** Rules of '%s' " % profile + "profile missing " +
                      "remediation: %d of %d [%d%% complete]" %
                      (rules_count - impl_fixes_count, rules_count,
                      profile_stats['implemented_fixes_pct']))
                self.console_print(profile_stats['missing_fixes'],
                                   console_width)

            if options.missing_cces and profile_stats['missing_cces']:
                print("***Rules of '%s' " % profile + "profile missing " +
                      "CCE identifier: %d of %d [%d%% complete]" %
                      (rules_count - impl_cces_count, rules_count,
                      profile_stats['assigned_cces_pct']))
                self.console_print(profile_stats['missing_cces'],
                                   console_width)

        else:
            # First delete the not requested information
            if not options.missing_ovals:
                del profile_stats['missing_ovals']
            if not options.missing_fixes:
                del profile_stats['missing_fixes']
            if not options.missing_cces:
                del profile_stats['missing_cces']
            if not options.implemented_ovals:
                del profile_stats['implemented_ovals']
                del profile_stats['implemented_ovals_pct']
            if not options.implemented_fixes:
                del profile_stats['implemented_fixes']
                del profile_stats['implemented_fixes_pct']
            if not options.assigned_cces:
                del profile_stats['assigned_cces']
                del profile_stats['assigned_cces_pct']

            return profile_stats

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
                      help="Show statistics for this XCCDF Profile only.")
    parser.add_option("-b", "--benchmark", default=False,
                      action="store", dest="benchmark_file",
                      help="Specify XCCDF benchmark to act on.")
    parser.add_option("--implemented-ovals", default=False,
                      action="store_true", dest="implemented_ovals",
                      help="Show also IDs of implemented OVAL checks.")
    parser.add_option("--missing-ovals", default=False,
                      action="store_true", dest="missing_ovals",
                      help="Show also IDs of unimplemented OVAL checks.")
    parser.add_option("--implemented-fixes", default=False,
                      action="store_true", dest="implemented_fixes",
                      help="Show also IDs of implemented remediations.")
    parser.add_option("--missing-fixes", default=False,
                      action="store_true", dest="missing_fixes",
                      help="Show also IDs of unimplemented remediations.")
    parser.add_option("--assigned-cces", default=False,
                      action="store_true", dest="assigned_cces",
                      help="Show IDs of rules having CCE assigned.")
    parser.add_option("--missing-cces", default=False,
                      action="store_true", dest="missing_cces",
                      help="Show IDs of rules missing CCE element.")
    parser.add_option("--implemented", default=False,
                      action="store_true", dest="implemented",
                      help="Equivalent like --implemented-ovals, \
                      --implemented_fixes, and --assigned-cves \
                      would be set.")
    parser.add_option("--missing", default=False,
                      action="store_true", dest="missing",
                      help="Equivalent like --missing-ovals, --missing-fixes, \
                      and --missing-cces would be set.")
    parser.add_option("--all", default=False,
                      action="store_true", dest="all",
                      help="Show all available statistics.")
    parser.add_option("--json", default=False,
                      action="store_true", dest="json",
                      help="Show the statistics in json file format.")

    (options, args) = parser.parse_args()
    if not options.benchmark_file:
        print("Missing XCCDF location via -b or --benchmark arguments!\n")
        parser.print_help()
        sys.exit(1)

    return (options, args)


def propagate_options(options):
    """Propagate child option values depending on selected parent options
       being specified"""

    if options.all:
        options.implemented = True
        options.missing = True

    if options.implemented:
        options.implemented_ovals = True
        options.implemented_fixes = True
        options.assigned_cces = True

    if options.missing:
        options.missing_ovals = True
        options.missing_fixes = True
        options.missing_cces = True

    return options


def main():
    (options, args) = parse_options()

    options = propagate_options(options)
    benchmark = XCCDFBenchmark(options.benchmark_file)
    if options.profile:
        profile = options.profile
        ret = benchmark.show_profile_stats(profile, options)
        if options.json:
            print(json.dumps(ret, indent=4))
    else:
        all_profile_elems = benchmark.tree.findall("./{%s}Profile" %
                                                   (xccdf_ns))
        ret = []
        for elem in all_profile_elems:
            profile = elem.get('id')
            if profile is not None:
                ret.append(benchmark.show_profile_stats(profile, options))

        if options.json:
            print(json.dumps(ret, indent=4))

if __name__ == '__main__':
    main()
