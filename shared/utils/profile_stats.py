#!/usr/bin/python2

script_usage = """
./profile_stats.py XCCDF_file [--profile XCCDF_file] [--full-stats]

Obtains and displays XCCDF profile statistics like:
* Count of rules present in the <xccdf:Profile>
* Count of rules having OVAL implemented [% of completion]
* Count of rules having remediation implemented [% of completion]

Unless --profile option was provided, it will display statistics
for all profiles found in the benchmark. Use --profile XCCDF_profile
to obtain statistics solely for particular profile.

If --full-stats option was provided it will also display the IDs
of unimplemented OVAL checks and remediation scripts.

NOTE: Does NOT work on DataStream benchmark format (yet)!
"""

import lxml.etree as ET
import re
import sys

xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
rem_system = "urn:xccdf:fix:script:sh"
console_width = 80

class rule_stats:
    def __init__(self, rid = None, roval = None, rfix = None):
        self.dict = { 'id' : rid,
                      'oval' : roval,
                      'fix' : rfix }


class xccdf_benchmark:
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


    def get_profile_stats(self, profile = None, full_stats = False):
        """Obtain statistics for the profile"""

        xccdf_profile = self.tree.find("./{%s}Profile[@id=\"%s\"]" % \
                                       (xccdf_ns, profile))
        if xccdf_profile is None:
            print("No such profile \"%s\" found in the benchmark!" % profile)
            print("* Available profiles:")
            profiles_avail = self.tree.findall("./{%s}Profile" % (xccdf_ns))
            for profile in profiles_avail:
                print("** %s" % profile.get('id'))
            sys.exit(1)

        rules = xccdf_profile.findall("./{%s}select[@selected=\"true\"]" % \
                                      xccdf_ns)
        for rule in rules:
            rule_id = rule.get('idref')
            xccdf_rule = self.tree.find(".//{%s}Rule[@id=\"%s\"]" % \
                                        (xccdf_ns, rule_id))
            if xccdf_rule is not None:
                oval = xccdf_rule.find("./{%s}check[@system=\"%s\"]" % \
                                        (xccdf_ns, oval_ns))
                fix = xccdf_rule.find("./{%s}fix[@system=\"%s\"]" % \
                                       (xccdf_ns, rem_system))
                self.stats.append(rule_stats(rule_id, oval, fix))


    def show_profile_stats(self, profile = None, full_stats = False):
        """Displays statistics for specific profile"""

        self.get_profile_stats(profile, full_stats)
        print("* Statistics of '%s' profile:" % profile)
        rules_count = len(self.stats)
        print("** Count of rules: %d" % rules_count)
        ovals_count = len([x for x in self.stats \
                           if x.dict['oval'] is not None])
        print("** Count of ovals: %d [%d%% complete]" % \
              (ovals_count, float(ovals_count) / rules_count * 100))
        fixes_count = len([x for x in self.stats if x.dict['fix'] is not None])
        print("** Count of fixes: %d [%d%% complete]" % \
              (fixes_count, float(fixes_count) / rules_count * 100))
        if full_stats:
            missing_ovals = [x.dict['id'] for x in self.stats \
                             if x.dict['oval'] is None]
            if missing_ovals:
                print("** Rules of '%s' profile missing OVAL:" % profile)
                self.console_print(missing_ovals, console_width)
            missing_fixes = [x.dict['id'] for x in self.stats \
                             if x.dict['fix'] is None]
            if missing_fixes:
                print("** Rules of '%s' profile missing remediation:" % \
                      profile)
                self.console_print(missing_fixes, console_width)
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


def usage():
    print("%s" % script_usage)
    sys.exit(1)

def main():

    if len(sys.argv) < 2:
        usage()

    benchmark = None
    matches = [x for x in sys.argv if re.search(r'.*\.xml', x) is not None]
    if matches:
        file_name = matches.pop()
        benchmark = xccdf_benchmark(file_name)

    full_stats = False
    if '--full-stats' in sys.argv:
        full_stats = True

    profile = None
    if '--profile' in sys.argv:
        profile = sys.argv[int(sys.argv.index('--profile')) + 1]

    if benchmark is not None:
        if profile is not None:
            benchmark.show_profile_stats(profile, full_stats)
        else:
            all_profile_elems = benchmark.tree.findall("./{%s}Profile" % \
                                                       (xccdf_ns))
            for elem in all_profile_elems:
                profile = elem.get('id')
                if profile is not None:
                    benchmark.show_profile_stats(profile, full_stats)

if __name__ == '__main__':
    main()
