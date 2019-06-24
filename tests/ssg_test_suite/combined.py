#!/usr/bin/env python2
from __future__ import print_function

import logging

from ssg.constants import OSCAP_PROFILE
from ssg_test_suite.common import send_scripts
from ssg_test_suite import rule
from ssg_test_suite import xml_operations
from ssg_test_suite import test_env
import data


class CombinedChecker(rule.RuleChecker):
    """
    Rule checks generally work like this -
    for every profile that supports that rule:

    - Alter the system.
    - Run the scan, check that the result meets expectations.
      If the test scenario passed as requested, return True,
      if it failed or passed unexpectedly, return False.

    The following sequence applies if the initial scan
    has failed as expected:

    - If there are no remediations, return True.
    - Run remediation, return False if it failed.
    - Return result of the final scan of remediated system.
    """
    def __init__(self, test_env):
        super(CombinedChecker, self).__init__(test_env)
        self._matching_rule_found = False

        self.results = list()
        self._current_result = None


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
