#!/usr/bin/env python2
from __future__ import print_function

import logging
import re

from ssg.constants import OSCAP_PROFILE
from ssg_test_suite.common import send_scripts
from ssg_test_suite import rule
from ssg_test_suite import xml_operations
from ssg_test_suite import test_env
import data


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
        self._matching_rule_found = False

        self.results = list()
        self._current_result = None

    def _modify_parameters(self, script, params):
        # Override any metadata in test scenario, wrt to profile to test
        # We already know that all target rules are part of the target profile
        params['profiles'] = [self.profile]
        return params

    # Check if a rule matches any of the targets to be tested
    # In CombinedChecker, we are looking for exact matches between rule and target
    def _matches_target(self, rule_dir, targets):
        for target in targets:
            # By prepending 'rule_', and match using endswith(), we should avoid
            # matching rules that are different by just a prefix or suffix
            if rule_dir.endswith("rule_"+target):
                return True, target
        return False, None

    def _test_target(self, target):
        try:
            remote_dir = send_scripts(self.test_env.domain_ip)
        except RuntimeError as exc:
            msg = "Unable to upload test scripts: {more_info}".format(more_info=str(exc))
            raise RuntimeError(msg)

        self._matching_rule_found = False

        with test_env.SavedState.create_from_environment(self.test_env, "tests_uploaded") as state:
            for rule in data.iterate_over_rules():
                matched, target_matched = self._matches_target(rule.directory, target)
                if not matched:
                    continue
                # In combined mode there is no expectations of matching substrings,
                # every entry in the target is expected to be unique.
                # Let's remove matched targets, so we can track rules not tested
                target.remove(target_matched)
                self._check_rule(rule, remote_dir, state)

        if len(target) != 0:
            target.sort()
            logging.info("The following rule(s) were not tested:")
            for rule in target:
                logging.info("{0}".format(rule))


def perform_combined_check(options):
    checker = CombinedChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean
    # No debug option is provided for combined mode
    checker.manual_debug = False
    checker.benchmark_cpes = options.benchmark_cpes
    checker.scenarios_regex = options.scenarios_regex
    # Let's keep track of originaly targeted profile
    checker.profile = options.target

    profile = options.target
    # check if target is a complete profile ID, if not prepend profile prefix
    if not profile.startswith(OSCAP_PROFILE):
        profile = OSCAP_PROFILE+profile
    logging.info("Performing combined test using profile: {0}".format(profile))

    # Fetch target list from rules selected in profile
    target_rules = xml_operations.get_all_rule_ids_in_profile(
            options.datastream, options.benchmark_id,
            profile, logging)
    logging.debug("Profile {0} expanded to following list of "
                  "rules: {1}".format(profile, target_rules))

    checker.test_target(target_rules)
