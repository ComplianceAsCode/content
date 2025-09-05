from __future__ import absolute_import
from __future__ import print_function

import os
import sys

from .build_yaml import ProfileWithInlinePolicies
from .xml import ElementTree
from .constants import XCCDF12_NS, datastream_namespace
from .constants import oval_namespace as oval_ns
from .constants import SCE_SYSTEM as sce_ns
from .constants import bash_system as bash_rem_system
from .constants import ansible_system as ansible_rem_system
from .constants import ignition_system as ignition_rem_system
from .constants import kubernetes_system as kubernetes_rem_system
from .constants import puppet_system as puppet_rem_system
from .constants import anaconda_system as anaconda_rem_system
from .constants import cce_uri
from .constants import ssg_version_uri
from .constants import stig_ns, cis_ns, hipaa_ns, anssi_ns
from .constants import ospp_ns, cui_ns, xslt_ns, ccn_ns, pcidss4_ns
from .constants import OSCAP_PROFILE
from .constants import SSG_REF_URIS
from .yaml import DocumentationNotComplete
console_width = 80


def make_name_to_profile_mapping(profile_files, env_yaml, product_cpes):
    name_to_profile = {}
    for f in profile_files:
        try:
            p = ProfileWithInlinePolicies.from_yaml(f, env_yaml, product_cpes)
            name_to_profile[p.id_] = p
        except Exception as exc:
            msg = "Not building profile from {fname}: {err}".format(
                fname=f, err=str(exc))
            if not isinstance(exc, DocumentationNotComplete):
                raise
            else:
                print(msg, file=sys.stderr)
    return name_to_profile


class RuleStats(object):
    """
    Class representing the content of a rule for statistics generation
    purposes.
    """
    def __init__(self, rule, cis_ns):
        self.id = rule.get("id")
        self.oval = rule.find('./{%s}check[@system="%s"]' % (XCCDF12_NS, oval_ns))
        self.sce = rule.find('./{%s}check[@system="%s"]' % (XCCDF12_NS, sce_ns))
        self.bash_fix = rule.find('./{%s}fix[@system="%s"]' % (XCCDF12_NS, bash_rem_system))
        self.ansible_fix = rule.find(
            './{%s}fix[@system="%s"]' % (XCCDF12_NS, ansible_rem_system)
        )
        self.ignition_fix = rule.find(
            './{%s}fix[@system="%s"]' % (XCCDF12_NS, ignition_rem_system)
        )
        self.kubernetes_fix = rule.find(
            './{%s}fix[@system="%s"]' % (XCCDF12_NS, kubernetes_rem_system)
        )
        self.puppet_fix = rule.find(
            './{%s}fix[@system="%s"]' % (XCCDF12_NS, puppet_rem_system)
        )
        self.anaconda_fix = rule.find(
            './{%s}fix[@system="%s"]' % (XCCDF12_NS, anaconda_rem_system)
        )
        self.cce = rule.find('./{%s}ident[@system="%s"]' % (XCCDF12_NS, cce_uri))
        self.stigid_ref = rule.find(
            './{%s}reference[@href="%s"]' % (XCCDF12_NS, SSG_REF_URIS["stigid"])
        )
        self.stigref_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, stig_ns))
        self.ccn_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, ccn_ns))
        self.cis_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, cis_ns))
        self.hipaa_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, hipaa_ns))
        self.anssi_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, anssi_ns))
        self.ospp_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, ospp_ns))
        self.pcidss4_ref = rule.find(
            './{%s}reference[@href="%s"]' % (XCCDF12_NS, pcidss4_ns)
        )
        self.cui_ref = rule.find('./{%s}reference[@href="%s"]' % (XCCDF12_NS, cui_ns))

        self.check = None
        if self.oval is not None:
            self.check = self.oval
        elif self.sce is not None:
            self.check = self.sce

        self.fix = None
        if self.bash_fix is not None:
            self.fix = self.bash_fix
        elif self.ansible_fix is not None:
            self.fix = self.ansible_fix
        elif self.ignition_fix is not None:
            self.fix = self.ignition_fix
        elif self.kubernetes_fix is not None:
            self.fix = self.kubernetes_fix
        elif self.puppet_fix is not None:
            self.fix = self.puppet_fix
        elif self.anaconda_fix is not None:
            self.fix = self.anaconda_fix


def get_cis_uri(product):
    cis_uri = cis_ns
    if product:
        constants_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            "products", product, "transforms/constants.xslt")
        if os.path.exists(constants_path):
            root = ElementTree.parse(constants_path)
            cis_var = root.find('./{%s}variable[@name="cisuri"]' % (xslt_ns))
            if cis_var is not None and cis_var.text:
                cis_uri = cis_var.text
    return cis_uri


class XCCDFBenchmark(object):
    """
    Class for processing an XCCDF benchmark to generate
    statistics about the profiles contained within it.
    """

    def __init__(self, filepath, product=""):
        self.tree = None
        try:
            with open(filepath, 'r') as xccdf_file:
                file_string = xccdf_file.read()
                tree = ElementTree.fromstring(file_string)
                if tree.tag == "{%s}Benchmark" % XCCDF12_NS:
                    self.tree = tree
                elif tree.tag == "{%s}data-stream-collection" % datastream_namespace:
                    benchmark_tree = tree.find(".//{%s}Benchmark" % XCCDF12_NS)
                    self.tree = benchmark_tree
                else:
                    raise ValueError("Unknown root element '%s'" % tree.tag)
        except IOError as ioerr:
            print("%s" % ioerr)
            sys.exit(1)

        self.indexed_rules = {}
        for rule in self.tree.findall(".//{%s}Rule" % (XCCDF12_NS)):
            rule_id = rule.get("id")
            if rule_id is None:
                raise RuntimeError("Can't index a rule with no id attribute!")

            if rule_id in self.indexed_rules:
                raise RuntimeError("Multiple rules exist with same id attribute: %s!" % rule_id)

            self.indexed_rules[rule_id] = rule
        self.cis_ns = get_cis_uri(product)

    def get_profile_stats(self, profile):
        """Obtain statistics for the profile"""

        # Holds the intermediary statistics for profile
        profile_stats = {
            'profile_id': "",
            'ssg_version': 0,
            'rules': [],
            'rules_count': 0,
            'implemented_ovals': [],
            'implemented_ovals_pct': 0,
            'missing_ovals': [],
            'implemented_sces': [],
            'implemented_sces_pct': 0,
            'missing_sces': [],
            'implemented_checks': [],
            'implemented_checks_pct': 0,
            'missing_checks': [],
            'implemented_bash_fixes': [],
            'implemented_bash_fixes_pct': 0,
            'implemented_ansible_fixes': [],
            'implemented_ansible_fixes_pct': 0,
            'implemented_ignition_fixes': [],
            'implemented_ignition_fixes_pct': 0,
            'implemented_kubernetes_fixes': [],
            'implemented_kubernetes_fixes_pct': 0,
            'implemented_puppet_fixes': [],
            'implemented_puppet_fixes_pct': 0,
            'implemented_anaconda_fixes': [],
            'implemented_anaconda_fixes_pct': 0,
            'missing_bash_fixes': [],
            'missing_ansible_fixes': [],
            'missing_ignition_fixes': [],
            'missing_kubernetes_fixes': [],
            'missing_puppet_fixes': [],
            'missing_anaconda_fixes': [],
            'implemented_fixes': [],
            'implemented_fixes_pct': 0,
            'missing_fixes': [],
            'assigned_cces': [],
            'assigned_cces_pct': 0,
            'missing_cces': [],
            'missing_stigid_refs': [],
            'missing_stigref_refs': [],
            'missing_ccn_refs': [],
            'missing_cis_refs': [],
            'missing_hipaa_refs': [],
            'missing_anssi_refs': [],
            'missing_ospp_refs': [],
            'missing_pcidss4_refs': [],
            'missing_cui_refs': [],
            'ansible_parity': [],
        }

        rule_stats = []
        ssg_version_elem = self.tree.find("./{%s}version[@update=\"%s\"]" %
                                          (XCCDF12_NS, ssg_version_uri))

        rules = []

        if profile == "all":
            # "all" is a virtual profile that selects all rules
            rules = self.indexed_rules.values()
        else:
            xccdf_profile = self.tree.find("./{%s}Profile[@id=\"%s\"]" %
                                           (XCCDF12_NS, profile))
            if xccdf_profile is None:
                print("No such profile \"%s\" found in the benchmark!"
                      % profile)
                print("* Available profiles:")
                profiles_avail = self.tree.findall(
                    "./{%s}Profile" % (XCCDF12_NS))
                for _profile in profiles_avail:
                    print("** %s" % _profile.get('id'))
                sys.exit(1)

            # This will only work with SSG where the (default) profile has zero
            # selected rule. If you want to reuse this for custom content, you
            # need to change this to look into Rule/@selected
            selects = xccdf_profile.findall("./{%s}select[@selected=\"true\"]" %
                                            XCCDF12_NS)

            for select in selects:
                rule_id = select.get('idref')
                xccdf_rule = self.indexed_rules.get(rule_id)
                if xccdf_rule is not None:
                    # it could also be a Group
                    rules.append(xccdf_rule)

        for rule in rules:
            if rule is not None:
                rule_stats.append(RuleStats(rule, self.cis_ns))

        if not rule_stats:
            print('Unable to retrieve statistics for %s profile' % profile)
            sys.exit(1)

        rule_stats.sort(key=lambda r: r.id)

        for rule in rule_stats:
            profile_stats['rules'].append(rule.id)

        profile_stats['profile_id'] = profile.replace(OSCAP_PROFILE, "")
        if ssg_version_elem is not None:
            profile_stats['ssg_version'] = \
                'SCAP Security Guide %s' % ssg_version_elem.text
        profile_stats['rules_count'] = len(rule_stats)
        profile_stats['implemented_ovals'] = \
            [x.id for x in rule_stats if x.oval is not None]
        profile_stats['implemented_ovals_pct'] = \
            float(len(profile_stats['implemented_ovals'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_ovals'] = \
            [x.id for x in rule_stats if x.oval is None]

        profile_stats['implemented_sces'] = \
            [x.id for x in rule_stats if x.sce is not None]
        profile_stats['implemented_sces_pct'] = \
            float(len(profile_stats['implemented_sces'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_sces'] = \
            [x.id for x in rule_stats if x.sce is None]

        profile_stats['implemented_checks'] = \
            [x.id for x in rule_stats if x.check is not None]
        profile_stats['implemented_checks_pct'] = \
            float(len(profile_stats['implemented_checks'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_checks'] = \
            [x.id for x in rule_stats if x.check is None]

        profile_stats['implemented_bash_fixes'] = \
            [x.id for x in rule_stats if x.bash_fix is not None]
        profile_stats['implemented_bash_fixes_pct'] = \
            float(len(profile_stats['implemented_bash_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_bash_fixes'] = \
            [x.id for x in rule_stats if x.bash_fix is None]

        profile_stats['implemented_ansible_fixes'] = \
            [x.id for x in rule_stats if x.ansible_fix is not None]
        profile_stats['implemented_ansible_fixes_pct'] = \
            float(len(profile_stats['implemented_ansible_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_ansible_fixes'] = \
            [x.id for x in rule_stats if x.ansible_fix is None]

        profile_stats['implemented_ignition_fixes'] = \
            [x.id for x in rule_stats if x.ignition_fix is not None]
        profile_stats['implemented_ignition_fixes_pct'] = \
            float(len(profile_stats['implemented_ignition_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_ignition_fixes'] = \
            [x.id for x in rule_stats if x.ignition_fix is None]

        profile_stats['implemented_kubernetes_fixes'] = \
            [x.id for x in rule_stats if x.kubernetes_fix is not None]
        profile_stats['implemented_kubernetes_fixes_pct'] = \
            float(len(profile_stats['implemented_kubernetes_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_kubernetes_fixes'] = \
            [x.id for x in rule_stats if x.kubernetes_fix is None]

        profile_stats['implemented_puppet_fixes'] = \
            [x.id for x in rule_stats if x.puppet_fix is not None]
        profile_stats['implemented_puppet_fixes_pct'] = \
            float(len(profile_stats['implemented_puppet_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_puppet_fixes'] = \
            [x.id for x in rule_stats if x.puppet_fix is None]

        profile_stats['implemented_anaconda_fixes'] = \
            [x.id for x in rule_stats if x.anaconda_fix is not None]

        profile_stats['implemented_fixes'] = \
            [x.id for x in rule_stats if x.fix is not None]
        profile_stats['implemented_fixes_pct'] = \
            float(len(profile_stats['implemented_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_fixes'] = \
            [x.id for x in rule_stats if x.fix is None]

        profile_stats['missing_stigid_refs'] = []
        if 'stig' in profile_stats['profile_id']:
            profile_stats['missing_stigid_refs'] = \
                [x.id for x in rule_stats if x.stigid_ref is None]

        profile_stats['missing_stigref_refs'] = []
        if 'stig' in profile_stats['profile_id']:
            profile_stats['missing_stigref_refs'] = \
                [x.id for x in rule_stats if x.stigref_ref is None]

        profile_stats['missing_ccn_refs'] = []
        if 'ccn' in profile_stats['profile_id']:
            profile_stats['missing_ccn_refs'] = \
                [x.id for x in rule_stats if x.ccn_ref is None]

        profile_stats['missing_cis_refs'] = []
        if 'cis' in profile_stats['profile_id']:
            profile_stats['missing_cis_refs'] = \
                [x.id for x in rule_stats if x.cis_ref is None]

        profile_stats['missing_hipaa_refs'] = []
        if 'hipaa' in profile_stats['profile_id']:
            profile_stats['missing_hipaa_refs'] = \
                [x.id for x in rule_stats if x.hipaa_ref is None]

        profile_stats['missing_anssi_refs'] = []
        if 'anssi' in profile_stats['profile_id']:
            profile_stats['missing_anssi_refs'] = \
                [x.id for x in rule_stats if x.anssi_ref is None]

        profile_stats['missing_ospp_refs'] = []
        if 'ospp' in profile_stats['profile_id']:
            profile_stats['missing_ospp_refs'] = \
                [x.id for x in rule_stats if x.ospp_ref is None]

        profile_stats['missing_pcidss4_refs'] = []
        if 'pci-dss' in profile_stats['profile_id']:
            profile_stats['missing_pcidss4_refs'] = \
                [x.id for x in rule_stats if x.pcidss4_ref is None]

        profile_stats['missing_cui_refs'] = []
        if 'cui' in profile_stats['profile_id']:
            profile_stats['missing_cui_refs'] = \
                [x.id for x in rule_stats if x.cui_ref is None]

        profile_stats['implemented_anaconda_fixes_pct'] = \
            float(len(profile_stats['implemented_anaconda_fixes'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_anaconda_fixes'] = \
            [x.id for x in rule_stats if x.anaconda_fix is None]

        profile_stats['assigned_cces'] = \
            [x.id for x in rule_stats if x.cce is not None]
        profile_stats['assigned_cces_pct'] = \
            float(len(profile_stats['assigned_cces'])) / \
            profile_stats['rules_count'] * 100
        profile_stats['missing_cces'] = \
            [x.id for x in rule_stats if x.cce is None]

        profile_stats['ansible_parity'] = \
            [rule_id for rule_id in profile_stats["missing_ansible_fixes"] if rule_id not in profile_stats["missing_bash_fixes"]]
        profile_stats['ansible_parity_pct'] = 0
        if len(profile_stats['implemented_bash_fixes']):
            profile_stats['ansible_parity_pct'] = \
                float(len(profile_stats['implemented_bash_fixes']) -
                      len(profile_stats['ansible_parity'])) / \
                len(profile_stats['implemented_bash_fixes']) * 100

        return profile_stats

    def show_profile_stats(self, profile, options):
        """Displays statistics for specific profile"""

        profile_stats = self.get_profile_stats(profile)
        rules_count = profile_stats['rules_count']
        impl_ovals_count = len(profile_stats['implemented_ovals'])
        impl_sces_count = len(profile_stats['implemented_sces'])
        impl_checks_count = len(profile_stats['implemented_checks'])
        impl_bash_fixes_count = len(profile_stats['implemented_bash_fixes'])
        impl_ansible_fixes_count = len(profile_stats['implemented_ansible_fixes'])
        impl_ignition_fixes_count = len(profile_stats['implemented_ignition_fixes'])
        impl_kubernetes_fixes_count = len(profile_stats['implemented_kubernetes_fixes'])
        impl_puppet_fixes_count = len(profile_stats['implemented_puppet_fixes'])
        impl_anaconda_fixes_count = len(profile_stats['implemented_anaconda_fixes'])
        impl_fixes_count = len(profile_stats['implemented_fixes'])
        missing_stigid_refs_count = len(profile_stats['missing_stigid_refs'])
        missing_stigref_refs_count = len(profile_stats['missing_stigref_refs'])
        missing_ccn_refs_count = len(profile_stats['missing_ccn_refs'])
        missing_cis_refs_count = len(profile_stats['missing_cis_refs'])
        missing_hipaa_refs_count = len(profile_stats['missing_hipaa_refs'])
        missing_anssi_refs_count = len(profile_stats['missing_anssi_refs'])
        missing_ospp_refs_count = len(profile_stats['missing_ospp_refs'])
        missing_pcidss4_refs_count = len(profile_stats['missing_pcidss4_refs'])
        missing_cui_refs_count = len(profile_stats['missing_cui_refs'])
        impl_cces_count = len(profile_stats['assigned_cces'])

        if options.format == "plain":
            if not options.skip_overall_stats:
                print("\nProfile %s:" % profile.replace(OSCAP_PROFILE, ""))
                print("* rules:              %d" % rules_count)
                print("* checks (OVAL):      %d\t[%d%% complete]" %
                      (impl_ovals_count,
                       profile_stats['implemented_ovals_pct']))
                print("* checks (SCE):       %d\t[%d%% complete]" %
                      (impl_sces_count,
                       profile_stats['implemented_sces_pct']))
                print("* checks (any):       %d\t[%d%% complete]" %
                      (impl_checks_count,
                       profile_stats['implemented_checks_pct']))

                print("* fixes (bash):       %d\t[%d%% complete]" %
                      (impl_bash_fixes_count,
                       profile_stats['implemented_bash_fixes_pct']))
                print("* fixes (ansible):    %d\t[%d%% complete]" %
                      (impl_ansible_fixes_count,
                       profile_stats['implemented_ansible_fixes_pct']))
                print("* fixes (ignition):   %d\t[%d%% complete]" %
                      (impl_ignition_fixes_count,
                       profile_stats['implemented_ignition_fixes_pct']))
                print("* fixes (kubernetes): %d\t[%d%% complete]" %
                      (impl_kubernetes_fixes_count,
                       profile_stats['implemented_kubernetes_fixes_pct']))
                print("* fixes (puppet):     %d\t[%d%% complete]" %
                      (impl_puppet_fixes_count,
                       profile_stats['implemented_puppet_fixes_pct']))
                print("* fixes (anaconda):   %d\t[%d%% complete]" %
                      (impl_anaconda_fixes_count,
                       profile_stats['implemented_anaconda_fixes_pct']))
                print("* fixes (any):        %d\t[%d%% complete]" %
                      (impl_fixes_count,
                       profile_stats['implemented_fixes_pct']))

                print("* CCEs:               %d\t[%d%% complete]" %
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

            if options.implemented_sces and \
               profile_stats['implemented_sces']:
                print("** Rules of '%s' " % profile +
                      "profile having SCE check: %d of %d [%d%% complete]" %
                      (impl_sces_count, rules_count,
                       profile_stats['implemented_sces_pct']))
                self.console_print(profile_stats['implemented_sces'],
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

                if profile_stats['implemented_ignition_fixes']:
                    print("*** Rules of '%s' profile having "
                          "a ignition fix script: %d of %d [%d%% complete]"
                          % (profile, impl_ignition_fixes_count, rules_count,
                             profile_stats['implemented_ignition_fixes_pct']))
                    self.console_print(
                        profile_stats['implemented_ignition_fixes'],
                        console_width)

                if profile_stats['implemented_kubernetes_fixes']:
                    print("*** Rules of '%s' profile having "
                          "a kubernetes fix script: %d of %d [%d%% complete]"
                          % (profile, impl_kubernetes_fixes_count, rules_count,
                             profile_stats['implemented_kubernetes_fixes_pct']))
                    self.console_print(
                        profile_stats['implemented_kubernetes_fixes'],
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

            if options.missing_sces and profile_stats['missing_sces']:
                print("*** Rules of '%s' " % profile + "profile missing " +
                      "SCE: %d of %d [%d%% complete]" %
                      (rules_count - impl_sces_count, rules_count,
                       profile_stats['implemented_sces_pct']))
                self.console_print(profile_stats['missing_sces'],
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

                if profile_stats['missing_ignition_fixes']:
                    print("*** rules of '%s' profile missing "
                          "a ignition fix script: %d of %d [%d%% complete]"
                          % (profile, rules_count - impl_ignition_fixes_count,
                             rules_count,
                             profile_stats['implemented_ignition_fixes_pct']))
                    self.console_print(profile_stats['missing_ignition_fixes'],
                                       console_width)

                if profile_stats['missing_kubernetes_fixes']:
                    print("*** rules of '%s' profile missing "
                          "a kubernetes fix script: %d of %d [%d%% complete]"
                          % (profile, rules_count - impl_kubernetes_fixes_count,
                             rules_count,
                             profile_stats['implemented_kubernetes_fixes_pct']))
                    self.console_print(profile_stats['missing_kubernetes_fixes'],
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

            if options.missing_stigid_refs and profile_stats['missing_stigid_refs']:
                print("*** rules of '%s' profile missing "
                      "stigid references: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_stigid_refs_count,
                         rules_count,
                         (100.0 * missing_stigid_refs_count / rules_count)))
                self.console_print(profile_stats['missing_stigid_refs'],
                                   console_width)

            if options.missing_stigref_refs and profile_stats['missing_stigref_refs']:
                print("*** rules of '%s' profile missing "
                      "stigref references: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_stigref_refs_count,
                         rules_count,
                         (100.0 * missing_stigref_refs_count / rules_count)))
                self.console_print(profile_stats['missing_stigref_refs'],
                                   console_width)

            if options.missing_ccn_refs and profile_stats['missing_ccn_refs']:
                print("*** rules of '%s' profile missing "
                      "CCN Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_ccn_refs_count,
                         rules_count,
                         (100.0 * missing_ccn_refs_count / rules_count)))
                self.console_print(profile_stats['missing_ccn_refs'],
                                   console_width)

            if options.missing_cis_refs and profile_stats['missing_cis_refs']:
                print("*** rules of '%s' profile missing "
                      "CIS Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_cis_refs_count,
                         rules_count,
                         (100.0 * missing_cis_refs_count / rules_count)))
                self.console_print(profile_stats['missing_cis_refs'],
                                   console_width)

            if options.missing_hipaa_refs and profile_stats['missing_hipaa_refs']:
                print("*** rules of '%s' profile missing "
                      "HIPAA Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_hipaa_refs_count,
                         rules_count,
                         (100.0 * missing_hipaa_refs_count / rules_count)))
                self.console_print(profile_stats['missing_hipaa_refs'],
                                   console_width)

            if options.missing_anssi_refs and profile_stats['missing_anssi_refs']:
                print("*** rules of '%s' profile missing "
                      "ANSSI Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_anssi_refs_count,
                         rules_count,
                         (100.0 * missing_anssi_refs_count / rules_count)))
                self.console_print(profile_stats['missing_anssi_refs'],
                                   console_width)

            if options.missing_ospp_refs and profile_stats['missing_ospp_refs']:
                print("*** rules of '%s' profile missing "
                      "OSPP Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_ospp_refs_count,
                         rules_count,
                         (100.0 * missing_ospp_refs_count / rules_count)))
                self.console_print(profile_stats['missing_ospp_refs'],
                                   console_width)

            if options.missing_pcidss4_refs and profile_stats['missing_pcidss4_refs']:
                print("*** rules of '%s' profile missing "
                      "PCI-DSS v4 Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_pcidss4_refs_count,
                         rules_count,
                         (100.0 * missing_pcidss4_refs_count / rules_count)))
                self.console_print(profile_stats['missing_pcidss4_refs'],
                                   console_width)

            if options.missing_cui_refs and profile_stats['missing_cui_refs']:
                print("*** rules of '%s' profile missing "
                      "CUI Refs: %d of %d have them [%d%% missing]"
                      % (profile, rules_count - missing_cui_refs_count,
                         rules_count,
                         (100.0 * missing_cui_refs_count / rules_count)))
                self.console_print(profile_stats['missing_cui_refs'],
                                   console_width)

            if options.missing_cces and profile_stats['missing_cces']:
                print("***Rules of '%s' " % profile + "profile missing " +
                      "CCE identifier: %d of %d [%d%% complete]" %
                      (rules_count - impl_cces_count, rules_count,
                       profile_stats['assigned_cces_pct']))
                self.console_print(profile_stats['missing_cces'],
                                   console_width)

            if options.ansible_parity:
                print("*** rules of '%s' profile with bash fix that implement "
                      "ansible fix scripts: %d out of %d [%d%% complete]"
                      % (profile, impl_bash_fixes_count - len(profile_stats['ansible_parity']),
                         impl_bash_fixes_count,
                         profile_stats['ansible_parity_pct']))
                self.console_print(profile_stats['ansible_parity'],
                                   console_width)

        elif options.format == "html":
            del profile_stats['implemented_ovals']
            del profile_stats['implemented_sces']
            del profile_stats['implemented_bash_fixes']
            del profile_stats['implemented_ansible_fixes']
            del profile_stats['implemented_ignition_fixes']
            del profile_stats['implemented_kubernetes_fixes']
            del profile_stats['implemented_puppet_fixes']
            del profile_stats['implemented_anaconda_fixes']
            del profile_stats['assigned_cces']

            profile_stats['missing_stigid_refs_count'] = missing_stigid_refs_count
            profile_stats['missing_stigref_refs_count'] = missing_stigref_refs_count
            profile_stats['missing_ccn_refs_count'] = missing_ccn_refs_count
            profile_stats['missing_cis_refs_count'] = missing_cis_refs_count
            profile_stats['missing_hipaa_refs_count'] = missing_hipaa_refs_count
            profile_stats['missing_anssi_refs_count'] = missing_anssi_refs_count
            profile_stats['missing_ospp_refs_count'] = missing_ospp_refs_count
            profile_stats['missing_pcidss4_refs_count'] = missing_pcidss4_refs_count
            profile_stats['missing_cui_refs_count'] = missing_cui_refs_count
            profile_stats['missing_ovals_count'] = len(profile_stats['missing_ovals'])
            profile_stats['missing_sces_count'] = len(profile_stats['missing_sces'])
            profile_stats['missing_bash_fixes_count'] = len(profile_stats['missing_bash_fixes'])
            profile_stats['missing_ansible_fixes_count'] = len(profile_stats['missing_ansible_fixes'])
            profile_stats['missing_ignition_fixes_count'] = len(profile_stats['missing_ignition_fixes'])
            profile_stats['missing_kubernetes_fixes_count'] = \
                    len(profile_stats['missing_kubernetes_fixes'])
            profile_stats['missing_puppet_fixes_count'] = len(profile_stats['missing_puppet_fixes'])
            profile_stats['missing_anaconda_fixes_count'] = len(profile_stats['missing_anaconda_fixes'])
            profile_stats['missing_cces_count'] = len(profile_stats['missing_cces'])

            del profile_stats['implemented_ovals_pct']
            del profile_stats['implemented_sces_pct']
            del profile_stats['implemented_bash_fixes_pct']
            del profile_stats['implemented_ansible_fixes_pct']
            del profile_stats['implemented_ignition_fixes_pct']
            del profile_stats['implemented_kubernetes_fixes_pct']
            del profile_stats['implemented_puppet_fixes_pct']
            del profile_stats['implemented_anaconda_fixes_pct']
            del profile_stats['assigned_cces_pct']
            del profile_stats['ssg_version']
            del profile_stats['ansible_parity_pct']
            del profile_stats['implemented_checks_pct']
            del profile_stats['implemented_fixes_pct']

            return profile_stats
        else:
            # First delete the not requested information
            if not options.missing_ovals:
                del profile_stats['missing_ovals']
            if not options.missing_sces:
                del profile_stats['missing_sces']
            if not options.missing_fixes:
                del profile_stats['missing_bash_fixes']
                del profile_stats['missing_ansible_fixes']
                del profile_stats['missing_ignition_fixes']
                del profile_stats['missing_kubernetes_fixes']
                del profile_stats['missing_puppet_fixes']
                del profile_stats['missing_anaconda_fixes']
                del profile_stats['missing_stigid_refs']
                del profile_stats['missing_stigref_refs']
                del profile_stats['missing_ccn_refs']
                del profile_stats['missing_cis_refs']
                del profile_stats['missing_hipaa_refs']
                del profile_stats['missing_anssi_refs']
                del profile_stats['missing_ospp_refs']
                del profile_stats['missing_pcidss4_refs']
                del profile_stats['missing_cui_refs']
            if not options.missing_cces:
                del profile_stats['missing_cces']
            if not options.implemented_ovals:
                del profile_stats['implemented_ovals']
            if not options.implemented_sces:
                del profile_stats['implemented_sces']
            if not options.implemented_fixes:
                del profile_stats['implemented_bash_fixes']
                del profile_stats['implemented_ansible_fixes']
                del profile_stats['implemented_ignition_fixes']
                del profile_stats['implemented_kubernetes_fixes']
                del profile_stats['implemented_puppet_fixes']
                del profile_stats['implemented_anaconda_fixes']
            if not options.assigned_cces:
                del profile_stats['assigned_cces']

            del profile_stats['rules']

            return profile_stats

    def _process_all_profile_stats(self, function_to_process_profile, *args):
        all_profile_elems = self.tree.findall("./{%s}Profile" % (XCCDF12_NS))
        ret = []
        for elem in all_profile_elems:
            profile = elem.get('id')
            if profile is not None:
                ret.append(function_to_process_profile(profile, *args))
        return ret

    def show_all_profile_stats(self, options):
        return self._process_all_profile_stats(self.show_profile_stats, options)

    def get_all_profile_stats(self):
        return self._process_all_profile_stats(self.get_profile_stats)

    def console_print(self, content, width):
        """Prints the 'content' array left aligned, each time 45 characters
           long, each row 'width' characters wide"""

        msg = ''
        for item in content:
            if len(msg) + len(item) < width - 6:
                msg += '   ' + "%-45s" % item
            else:
                print("%s" % msg)
                msg = '   ' + "%-45s" % item
        if msg != '':
            print("%s" % msg)
