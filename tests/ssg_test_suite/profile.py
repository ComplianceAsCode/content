#!/usr/bin/env python2
from __future__ import print_function

import logging


import ssg_test_suite.oscap
from ssg_test_suite.rule import get_viable_profiles

logging.getLogger(__name__).addHandler(logging.NullHandler())


class ProfileChecker(ssg_test_suite.oscap.Checker):
    """
    Iterate over profiles in datastream and perform scanning of unaltered system
    using every profile according to input. Also perform remediation run.
    Return value not defined, textual output and generated reports is the result.
    """
    def _test_target(self, target):
        profiles = get_viable_profiles(
            target, self.datastream, self.benchmark_id)
        self.run_test_for_all_profiles(profiles)

    def _run_test(self, profile, test_data):
        self.executed_tests += 1

        runner_cls = ssg_test_suite.oscap.REMEDIATION_PROFILE_RUNNERS[self.remediate_using]
        runner = runner_cls(
            self.test_env, profile, self.datastream, self.benchmark_id)

        for stage in ("initial", "remediation", "final"):
            result = runner.run_stage(stage)
            if result:
                logging.info("Evaluation of the profile has passed: {0} ({1} stage).".format(profile, stage))
            else:
                logging.error("Evaluation of the profile has failed: {0} ({1} stage).".format(profile, stage))


def perform_profile_check(options):
    checker = ProfileChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using

    checker.test_target(options.target)
