#!/usr/bin/env python2

import json
import argparse
import sys

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

script_desc = \
    "Obtains and displays XCCDF profile statistics. Namely number " + \
    "of rules in the profile, how many of these rules have their OVAL " + \
    "check implemented, how many have a remediation available, ..."


xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
bash_rem_system = "urn:xccdf:fix:script:sh"
ansible_rem_system = "urn:xccdf:fix:script:ansible"
puppet_rem_system = "urn:xccdf:fix:script:puppet"
anaconda_rem_system = "urn:redhat:anaconda:pre"
cce_system = "https://nvd.nist.gov/cce/index.cfm"
ssg_version_uri = \
    "https://github.com/OpenSCAP/scap-security-guide/releases/latest"
console_width = 80


class RuleStats(object):
    def __init__(self, rid=None, roval=None,
                 rbash_fix=None, ransible_fix=None,
                 rpuppet_fix=None, ranaconda_fix=None,
                 rcce=None):
        self.dict = {
            'id': rid,
            'oval': roval,
            'bash_fix': rbash_fix,
            'ansible_fix': ransible_fix,
            'puppet_fix': rpuppet_fix,
            'anaconda_fix': ranaconda_fix,
            'cce': rcce
        }


class XCCDFBenchmark(object):
    def __init__(self, filepath):
        self.tree = None
        try:
            with open(filepath, 'r') as xccdf_file:
                file_string = xccdf_file.read()
                tree = ElementTree.fromstring(file_string)
                self.tree = tree
        except IOError as ioerr:
            print("%s" % ioerr)
            sys.exit(1)

        self.indexed_rules = {}
        for rule in self.tree.findall(".//{%s}Rule" % (xccdf_ns)):
            rule_id = rule.get("id")
            if rule_id is None:
                raise RuntimeError("Can't index a rule with no id attribute!")

            assert(rule_id not in self.indexed_rules)
            self.indexed_rules[rule_id] = rule

    def get_profile_stats(self, profile):
        """Obtain statistics for the profile"""

        # Holds the intermediary statistics for profile
        profile_stats = {
            'profile_id': None,
            'ssg_version': 0,
            'rules_count': 0,
            'implemented_ovals': [],
            'implemented_ovals_pct': 0,
            'missing_ovals': [],
            'implemented_bash_fixes': [],
            'implemented_bash_fixes_pct': 0,
            'implemented_ansible_fixes': [],
            'implemented_ansible_fixes_pct': 0,
            'implemented_puppet_fixes': [],
            'implemented_puppet_fixes_pct': 0,
            'implemented_anaconda_fixes': [],
            'implemented_anaconda_fixes_pct': 0,
            'missing_bash_fixes': [],
            'missing_ansible_fixes': [],
            'missing_puppet_fixes': [],
            'missing_anaconda_fixes': [],
            'assigned_cces': [],
            'assigned_cces_pct': 0,
            'missing_cces': []
        }

        rule_stats = []
        ssg_version_elem = self.tree.find("./{%s}version[@update=\"%s\"]" %
                                          (xccdf_ns, ssg_version_uri))

        rules = []

        if profile == "all":
            # "all" is a virtual profile that selects all rules
            rules = self.indexed_rules.values()
        else:
            xccdf_profile = self.tree.find("./{%s}Profile[@id=\"%s\"]" %
                                           (xccdf_ns, profile))
            if xccdf_profile is None:
                print("No such profile \"%s\" found in the benchmark!"
                      % profile)
                print("* Available profiles:")
                profiles_avail = self.tree.findall("./{%s}Profile" % (xccdf_ns))
                for profile in profiles_avail:
                    print("** %s" % profile.get('id'))
                sys.exit(1)

            # This will only work with SSG where the (default) profile has zero
            # selected rule. If you want to reuse this for custom content, you
            # need to change this to look into Rule/@selected
            selects = xccdf_profile.findall("./{%s}select[@selected=\"true\"]" %
                                            xccdf_ns)

            for select in selects:
                rule_id = select.get('idref')
                xccdf_rule = self.indexed_rules.get(rule_id)
                if xccdf_rule is not None:
                    # it could also be a Group
                    rules.append(xccdf_rule)

        for rule in rules:
            if rule is not None:
                oval = rule.find("./{%s}check[@system=\"%s\"]" %
                                 (xccdf_ns, oval_ns))
                bash_fix = rule.find("./{%s}fix[@system=\"%s\"]" %
                                     (xccdf_ns, bash_rem_system))
                ansible_fix = rule.find("./{%s}fix[@system=\"%s\"]" %
                                        (xccdf_ns, ansible_rem_system))
                puppet_fix = rule.find("./{%s}fix[@system=\"%s\"]" %
                                       (xccdf_ns, puppet_rem_system))
                anaconda_fix = rule.find("./{%s}fix[@system=\"%s\"]" %
                                         (xccdf_ns, anaconda_rem_system))
                cce = rule.find("./{%s}ident[@system=\"%s\"]" %
                                (xccdf_ns, cce_system))
                rule_stats.append(
                    RuleStats(rule.get("id"), oval,
                              bash_fix, ansible_fix, puppet_fix, anaconda_fix,
                              cce)
                )

        if not rule_stats:
            print('Unable to retrieve statistics for %s profile' % profile)
            sys.exit(1)
        
        rule_stats.sort(key=lambda r: r.dict['id'])

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

        profile_stats['implemented_bash_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['bash_fix'] is not None]
        profile_stats['implemented_bash_fixes_pct'] = \
            float(len(profile_stats['implemented_bash_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_bash_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['bash_fix'] is None]

        profile_stats['implemented_ansible_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['ansible_fix'] is not None]
        profile_stats['implemented_ansible_fixes_pct'] = \
            float(len(profile_stats['implemented_ansible_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_ansible_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['ansible_fix'] is None]

        profile_stats['implemented_puppet_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['puppet_fix'] is not None]
        profile_stats['implemented_puppet_fixes_pct'] = \
            float(len(profile_stats['implemented_puppet_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_puppet_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['puppet_fix'] is None]

        profile_stats['implemented_anaconda_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['anaconda_fix'] is not None]
        profile_stats['implemented_anaconda_fixes_pct'] = \
            float(len(profile_stats['implemented_anaconda_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_anaconda_fixes'] = \
            [x.dict['id'] for x in rule_stats if x.dict['anaconda_fix'] is None]

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
        impl_bash_fixes_count = len(profile_stats['implemented_bash_fixes'])
        impl_ansible_fixes_count = len(profile_stats['implemented_ansible_fixes'])
        impl_puppet_fixes_count = len(profile_stats['implemented_puppet_fixes'])
        impl_anaconda_fixes_count = len(profile_stats['implemented_anaconda_fixes'])
        impl_cces_count = len(profile_stats['assigned_cces'])

        if options.format == "plain":
            print("\nProfile %s:" % profile)
            print("* rules:            %d" % rules_count)
            print("* checks (OVAL):    %d\t[%d%% complete]" %
                  (impl_ovals_count,
                   profile_stats['implemented_ovals_pct']))

            print("* fixes (bash):     %d\t[%d%% complete]" %
                  (impl_bash_fixes_count,
                   profile_stats['implemented_bash_fixes_pct']))
            print("* fixes (ansible):  %d\t[%d%% complete]" %
                  (impl_ansible_fixes_count,
                   profile_stats['implemented_ansible_fixes_pct']))
            print("* fixes (puppet):   %d\t[%d%% complete]" %
                  (impl_puppet_fixes_count,
                   profile_stats['implemented_puppet_fixes_pct']))
            print("* fixes (anaconda): %d\t[%d%% complete]" %
                  (impl_anaconda_fixes_count,
                   profile_stats['implemented_anaconda_fixes_pct']))

            print("* CCEs:             %d\t[%d%% complete]" %
                  (impl_cces_count,
                   profile_stats['assigned_cces_pct']))

            if options.implemented_ovals and \
               profile_stats['implemented_ovals']:
                print("** Rules of '%s' " % profile +
                      "profile having OVAL check: %d of %d [%d%% complete]" %
                      (impl_ovals_count, rules_count,
                       profile_stats['implemented_ovals_pct']))
                self.console_print(profile_stats['implemented_ovals'],
                                   console_width)

            if options.implemented_fixes:
                if profile_stats['implemented_bash_fixes']:
                    print("*** Rules of '%s' profile having "
                          "a bash fix script: %d of %d [%d%% complete]"
                          % (profile, impl_bash_fixes_count, rules_count,
                             profile_stats['implemented_bash_fixes_pct']))
                    self.console_print(profile_stats['implemented_bash_fixes'],
                                       console_width)

                if profile_stats['implemented_ansible_fixes']:
                    print("*** Rules of '%s' profile having "
                          "a ansible fix script: %d of %d [%d%% complete]"
                          % (profile, impl_ansible_fixes_count, rules_count,
                             profile_stats['implemented_ansible_fixes_pct']))
                    self.console_print(
                        profile_stats['implemented_ansible_fixes'],
                        console_width)

                if profile_stats['implemented_puppet_fixes']:
                    print("*** Rules of '%s' profile having "
                          "a puppet fix script: %d of %d [%d%% complete]"
                          % (profile, impl_puppet_fixes_count, rules_count,
                             profile_stats['implemented_puppet_fixes_pct']))
                    self.console_print(
                        profile_stats['implemented_puppet_fixes'],
                        console_width)

                if profile_stats['implemented_anaconda_fixes']:
                    print("*** Rules of '%s' profile having "
                          "a anaconda fix script: %d of %d [%d%% complete]"
                          % (profile, impl_anaconda_fixes_count, rules_count,
                             profile_stats['implemented_anaconda_fixes_pct']))
                    self.console_print(
                        profile_stats['implemented_anaconda_fixes'],
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

            if options.missing_fixes:
                if profile_stats['missing_bash_fixes']:
                    print("*** rules of '%s' profile missing "
                          "a bash fix script: %d of %d [%d%% complete]"
                          % (profile, rules_count - impl_bash_fixes_count,
                             rules_count,
                             profile_stats['implemented_bash_fixes_pct']))
                    self.console_print(profile_stats['missing_bash_fixes'],
                                       console_width)

                if profile_stats['missing_ansible_fixes']:
                    print("*** rules of '%s' profile missing "
                          "a ansible fix script: %d of %d [%d%% complete]"
                          % (profile, rules_count - impl_ansible_fixes_count,
                             rules_count,
                             profile_stats['implemented_ansible_fixes_pct']))
                    self.console_print(profile_stats['missing_ansible_fixes'],
                                       console_width)

                if profile_stats['missing_puppet_fixes']:
                    print("*** rules of '%s' profile missing "
                          "a puppet fix script: %d of %d [%d%% complete]"
                          % (profile, rules_count - impl_puppet_fixes_count,
                             rules_count,
                             profile_stats['implemented_puppet_fixes_pct']))
                    self.console_print(profile_stats['missing_puppet_fixes'],
                                       console_width)

                if profile_stats['missing_anaconda_fixes']:
                    print("*** rules of '%s' profile missing "
                          "a anaconda fix script: %d of %d [%d%% complete]"
                          % (profile, rules_count - impl_anaconda_fixes_count,
                             rules_count,
                             profile_stats['implemented_anaconda_fixes_pct']))
                    self.console_print(profile_stats['missing_anaconda_fixes'],
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
                del profile_stats['missing_bash_fixes']
                del profile_stats['missing_ansible_fixes']
                del profile_stats['missing_puppet_fixes']
                del profile_stats['missing_anaconda_fixes']
            if not options.missing_cces:
                del profile_stats['missing_cces']
            if not options.implemented_ovals:
                del profile_stats['implemented_ovals']
            if not options.implemented_fixes:
                del profile_stats['implemented_bash_fixes']
                del profile_stats['implemented_ansible_fixes']
                del profile_stats['implemented_puppet_fixes']
                del profile_stats['implemented_anaconda_fixes']
            if not options.assigned_cces:
                del profile_stats['assigned_cces']

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


def main():
    parser = argparse.ArgumentParser(description=script_desc)
    parser.add_argument("--profile", "-p",
                        action="store",
                        help="Show statistics for this XCCDF Profile only. If "
                        "not provided the script will show stats for all "
                        "available profiles.")
    parser.add_argument("--benchmark", "-b", required=True,
                        action="store",
                        help="Specify XCCDF file to act on. Must be a plain "
                        "XCCDF file, doesn't work on source datastreams yet!")
    parser.add_argument("--implemented-ovals", default=False,
                        action="store_true", dest="implemented_ovals",
                        help="Show IDs of implemented OVAL checks.")
    parser.add_argument("--missing-ovals", default=False,
                        action="store_true", dest="missing_ovals",
                        help="Show IDs of unimplemented OVAL checks.")
    parser.add_argument("--implemented-fixes", default=False,
                        action="store_true", dest="implemented_fixes",
                        help="Show IDs of implemented remediations.")
    parser.add_argument("--missing-fixes", default=False,
                        action="store_true", dest="missing_fixes",
                        help="Show IDs of unimplemented remediations.")
    parser.add_argument("--assigned-cces", default=False,
                        action="store_true", dest="assigned_cces",
                        help="Show IDs of rules having CCE assigned.")
    parser.add_argument("--missing-cces", default=False,
                        action="store_true", dest="missing_cces",
                        help="Show IDs of rules missing CCE element.")
    parser.add_argument("--implemented", default=False,
                        action="store_true",
                        help="Equivalent of --implemented-ovals, "
                        "--implemented_fixes and --assigned-cves "
                        "all being set.")
    parser.add_argument("--missing", default=False,
                        action="store_true",
                        help="Equivalent of --missing-ovals, --missing-fixes"
                        " and --missing-cces all being set.")
    parser.add_argument("--all", default=False,
                        action="store_true", dest="all",
                        help="Show all available statistics.")
    parser.add_argument("--format", default="plain",
                        choices=["plain", "json", "csv"],
                        help="Which format to use for output.")

    args, unknown = parser.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    if args.all:
        args.implemented = True
        args.missing = True

    if args.implemented:
        args.implemented_ovals = True
        args.implemented_fixes = True
        args.assigned_cces = True

    if args.missing:
        args.missing_ovals = True
        args.missing_fixes = True
        args.missing_cces = True

    benchmark = XCCDFBenchmark(args.benchmark)
    ret = []
    if args.profile:
        ret.append(benchmark.show_profile_stats(args.profile, args))
    else:
        all_profile_elems = benchmark.tree.findall("./{%s}Profile" % (xccdf_ns))
        ret = []
        for elem in all_profile_elems:
            profile = elem.get('id')
            if profile is not None:
                ret.append(benchmark.show_profile_stats(profile, args))

    if args.format == "json":
        print(json.dumps(ret, indent=4))
    elif args.format == "csv":
        # we can assume ret has at least one element
        # CSV header
        print(",".join(ret[0].keys()))
        for line in ret:
            print(",".join([str(value) for value in line.values()]))


if __name__ == '__main__':
    main()
