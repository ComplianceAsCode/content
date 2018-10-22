#!/usr/bin/env python2
from __future__ import print_function

import logging
import os
import json

import ssg_test_suite.oscap
import ssg_test_suite.virt
from ssg_test_suite import common
from ssg_test_suite import xml_operations
from ssg_test_suite.rule import get_viable_profiles
from ssg_test_suite.log import LogHelper

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
        self.results = {}

        logging.info("Evaluation of profile {0}.".format(profile))
        self.executed_tests += 1

        runner_cls = ssg_test_suite.oscap.REMEDIATION_PROFILE_RUNNERS[self.remediate_using]
        runner = runner_cls(
            self.test_env, profile, self.datastream, self.benchmark_id)
        results_file = runner.results_path

        stage = "initial_scan"
        result = runner.run_stage(stage)
        results = xml_operations.get_rule_results_from_profile_result_file(runner.results_path)

        self.define_current_results_with_stage(profile, stage, results)

        for stage in ("remediation", "final_scan"):
            result = runner.run_stage(stage)

        # Normally, the results are in the final stage, but oscap final scan may be skipped
        # by the oscap remediation
        stage_with_final_results = stage
        # There may be no results for remediation (consider e.g. Ansible remediation),
        # so for results, we go for the final scan.
        results = xml_operations.get_rule_results_from_profile_result_file(runner.results_path)
        self.update_current_results_with_stage(stage_with_final_results, results)

        self.results = [r.save_to_dict() for r in self.results.values()]
        with open(os.path.join(LogHelper.LOG_DIR, "results.json"), "w") as f:
            json.dump(self.results, f)

        return result

    def define_current_results_with_stage(self, profile, stage, results):
        for rid, value in results.items():
            self.results[rid] = common.ProfileResult()
            self.results[rid].scenario = common.Run_id(rid, profile)
            self.results[rid].conditions = common.Run_conditions(
                backend=self.test_env.name, scanning_mode=self.test_env.scanning_mode,
                remediated_by=self.remediate_using, datastream=self.datastream)
            self.results[rid].when = self.test_timestamp_str

        self.update_current_results_with_stage(stage, results)

    def update_current_results_with_stage(self, stage, results):
        for rid, value in results.items():
            rule_result = value
            self.results[rid].record_stage_result(stage, rule_result)


def perform_profile_check(options):
    checker = ProfileChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using

    checker.test_target(options.target)
