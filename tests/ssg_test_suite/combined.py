#!/usr/bin/python3
from __future__ import print_function

import logging
import re

from ssg.constants import OSCAP_PROFILE
from ssg_test_suite import common
from ssg_test_suite import rule
from ssg_test_suite import xml_operations
from ssg_test_suite import test_env


class CombinedChecker(rule.RuleChecker):
    """
    Combined mode works like pretty much like the Rule mode -
    for every rule selected in a profile:

    - Alter the system.
    - Run the scan, check that the result meets expectations.
      If the test scenario passed as requested, return True,
      if it failed or passed unexpectedly, return False.

    The following sequence applies if the initial scan
    has failed as expected:

    - If there are no remediations, return True.
    - Run remediation, return False if it failed.
    - Return result of the final scan of remediated system.

    If a rule doesn't have any test scenario, it is skipped.
    Skipped rules are reported at the end.
    """
    def __init__(self, test_env):
        super(CombinedChecker, self).__init__(test_env)

        self.rules_not_tested_yet = set()
        self.results = list()
        self._current_result = None
        self.run_aborted = False

    def _rule_matches_rule_spec(self, rule_short_id):
        return (rule_short_id in self.rule_spec)

    def _modify_parameters(self, script, params):
        # If there is no profiles metadata in a script we will use
        # the ALL profile - this will prevent failures which might
        # be caused by the tested profile selecting different values
        # in tested variables compared to defaults. The ALL profile
        # is always selecting default values.
        # If there is profiles metadata we check the metadata and set
        # it to self.profile (the tested profile) only if the metadata
        # contains self.profile - otherwise scenario is not supposed to
        # be tested using the self.profile and we return empty profiles
        # metadata.
        if not params["profiles"]:
            params["profiles"].append(rule.OSCAP_PROFILE_ALL_ID)
            logging.debug(
                "Added the {0} profile to the list of available profiles for {1}"
                .format(rule.OSCAP_PROFILE_ALL_ID, script))
        else:
            params['profiles'] = [item for item in params['profiles'] if re.search(self.profile, item)]
        return params

    def _generate_target_rules(self, profile):
        # check if target is a complete profile ID, if not prepend profile prefix
        if not profile.startswith(OSCAP_PROFILE):
            profile = OSCAP_PROFILE + profile
        logging.info("Performing combined test using profile: {0}".format(profile))

        # Fetch target list from rules selected in profile
        target_rules = xml_operations.get_all_rule_ids_in_profile(
                self.datastream, self.benchmark_id,
                profile, logging)
        logging.debug("Profile {0} expanded to following list of "
                      "rules: {1}".format(profile, target_rules))
        return target_rules

    def _test_target(self):
        self.rules_not_tested_yet = set(self.rule_spec)

        try:
            super(CombinedChecker, self)._test_target()
        except KeyboardInterrupt as exec_interrupt:
            self.run_aborted = True
            raise exec_interrupt

        if len(self.rules_not_tested_yet) != 0:
            not_tested = sorted(list(self.rules_not_tested_yet))
            logging.info("The following rule(s) were not tested:")
            for rule in not_tested:
                logging.info("{0}".format(rule))

    def test_rule(self, state, rule, scenarios):
        super(CombinedChecker, self).test_rule(state, rule, scenarios)
        # In combined mode there is no expectations of matching substrings,
        # every entry in the target is expected to be unique.
        # Let's remove matched targets, so we can track rules not tested
        self.rules_not_tested_yet.discard(rule.short_id)

def perform_combined_check(options):
    checker = CombinedChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean
    checker.no_reports = options.no_reports
    # No debug option is provided for combined mode
    checker.manual_debug = False
    checker.benchmark_cpes = options.benchmark_cpes
    checker.scenarios_regex = options.scenarios_regex
    checker.scenarios_profile = None
    checker.slice_current = options.slice_current
    checker.slice_total = options.slice_total
    for profile in options.target:
        # Let's keep track of originally targeted profile
        checker.profile = profile
        target_rules = checker._generate_target_rules(profile)

        checker.rule_spec = target_rules
        checker.template_spec = None
        checker.test_target()
        if checker.run_aborted:
            return
