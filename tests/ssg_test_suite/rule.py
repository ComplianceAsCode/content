#!/usr/bin/env python2
from __future__ import print_function

import logging
import os
import os.path
import re
import subprocess
import collections
import json
import fnmatch

from ssg.constants import OSCAP_PROFILE, OSCAP_PROFILE_ALL_ID, OSCAP_RULE
from ssg_test_suite import oscap
from ssg_test_suite import xml_operations
from ssg_test_suite import test_env
from ssg_test_suite import common
from ssg_test_suite.log import LogHelper


logging.getLogger(__name__).addHandler(logging.NullHandler())


Scenario = collections.namedtuple(
    "Scenario", ["script", "context", "script_params"])


def get_viable_profiles(selected_profiles, datastream, benchmark):
    """Read datastream, and return set intersection of profiles of given
    benchmark and those provided in `selected_profiles` parameter.
    """

    valid_profiles = []
    all_profiles_elements = xml_operations.get_all_profiles_in_benchmark(
        datastream, benchmark, logging)
    all_profiles = [el.attrib["id"] for el in all_profiles_elements]
    all_profiles.append(OSCAP_PROFILE_ALL_ID)

    for ds_profile in all_profiles:
        if 'ALL' in selected_profiles:
            valid_profiles += [ds_profile]
            continue
        for sel_profile in selected_profiles:
            if ds_profile.endswith(sel_profile):
                valid_profiles += [ds_profile]

    if not valid_profiles:
        logging.warning('No profile ends with "{0}"'
                      .format(", ".join(selected_profiles)))
    return valid_profiles


def _apply_script(rule_dir, domain_ip, script):
    """Run particular test script on VM and log it's output."""
    machine = "{0}@{1}".format(common.REMOTE_USER, domain_ip)
    logging.debug("Applying script {0}".format(script))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(
        LogHelper.LOG_DIR, rule_name + ".prescripts.log")

    with open(log_file_name, 'a') as log_file:
        log_file.write('##### {0} / {1} #####\n'.format(rule_name, script))
        shared_dir = os.path.join(common.REMOTE_TEST_SCENARIOS_DIRECTORY, "shared")
        command = "cd {0}; SHARED={1} bash -x {2}".format(rule_dir, shared_dir, script)
        args = common.SSH_ADDITIONAL_OPTS + (machine, command)

        try:
            common.run_with_stdout_logging("ssh", args, log_file)
        except subprocess.CalledProcessError as exc:
            logging.error("Rule testing script {script} failed with exit code {rc}"
                          .format(script=script, rc=exc.returncode))
            return False
    return True


def _get_script_context(script):
    """Return context of the script."""
    result = re.search(r'.*\.([^.]*)\.[^.]*$', script)
    if result is None:
        return None
    return result.group(1)


class RuleChecker(oscap.Checker):
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
        super(RuleChecker, self).__init__(test_env)
        self._matching_rule_found = False

        self.results = list()
        self._current_result = None

    def _run_test(self, profile, test_data):
        scenario = test_data["scenario"]
        rule_id = test_data["rule_id"]
        remediation_available = test_data["remediation_available"]

        LogHelper.preload_log(
            logging.INFO, "Script {0} using profile {1} OK".format(scenario.script, profile),
            log_target='pass')
        LogHelper.preload_log(
            logging.ERROR,
            "Script {0} using profile {1} found issue:".format(scenario.script, profile),
            log_target='fail')

        runner_cls = oscap.REMEDIATION_RULE_RUNNERS[self.remediate_using]
        runner = runner_cls(
            self.test_env, oscap.process_profile_id(profile), self.datastream, self.benchmark_id,
            rule_id, scenario.script, self.dont_clean, self.manual_debug)
        if not self._initial_scan_went_ok(runner, rule_id, scenario.context):
            return False

        supported_and_available_remediations = self._get_available_remediations(scenario)
        if (scenario.context not in ['fail', 'error']
                or not supported_and_available_remediations):
            return True

        if remediation_available:
            if not self._remediation_went_ok(runner, rule_id):
                return False

            return self._final_scan_went_ok(runner, rule_id)
        else:
            msg = ("No remediation is available for rule '{}'."
                   .format(rule_id))
            logging.warning(msg)
            return False

    def _initial_scan_went_ok(self, runner, rule_id, context):
        success = runner.run_stage_with_context("initial", context)
        self._current_result.record_stage_result("initial_scan", success)
        if not success:
            msg = ("The initial scan failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _is_remediation_available(self, rule):
        if xml_operations.find_fix_in_benchmark(
                self.datastream, self.benchmark_id, rule.id, self.remediate_using) is None:
            return False
        else:
            return True


    def _get_available_remediations(self, scenario):
        is_supported = set(['all'])
        is_supported.add(
            oscap.REMEDIATION_RUNNER_TO_REMEDIATION_MEANS[self.remediate_using])
        supported_and_available_remediations = set(
            scenario.script_params['remediation']).intersection(is_supported)
        return supported_and_available_remediations

    def _remediation_went_ok(self, runner, rule_id):
        success = runner.run_stage_with_context('remediation', 'fixed')
        self._current_result.record_stage_result("remediation", success)
        if not success:
            msg = ("The remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)

        return success

    def _final_scan_went_ok(self, runner, rule_id):
        success = runner.run_stage_with_context('final', 'pass')
        self._current_result.record_stage_result("final_scan", success)
        if not success:
            msg = ("The check after remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _rule_should_be_tested(self, rule_id, rules_to_be_tested):
        if 'ALL' in rules_to_be_tested:
            return True
        else:
            for rule_to_be_tested in rules_to_be_tested:
                # we check for a substring
                if rule_to_be_tested.startswith(OSCAP_RULE):
                    pattern = rule_to_be_tested
                else:
                    pattern = OSCAP_RULE + rule_to_be_tested
                if fnmatch.fnmatch(rule_id, pattern):
                    return True
            return False

    def _test_target(self, target):
        try:
            remote_dir = common.send_scripts(self.test_env.domain_ip)
        except RuntimeError as exc:
            msg = "Unable to upload test scripts: {more_info}".format(more_info=str(exc))
            raise RuntimeError(msg)

        self._matching_rule_found = False

        with test_env.SavedState.create_from_environment(self.test_env, "tests_uploaded") as state:
            for rule in common.iterate_over_rules():
                if not self._rule_should_be_tested(rule.id, target):
                    continue
                self._matching_rule_found = True
                if not xml_operations.find_rule_in_benchmark(
                        self.datastream, self.benchmark_id, rule.id):
                    logging.error(
                        "Rule '{0}' isn't present in benchmark '{1}' in '{2}'"
                        .format(rule.id, self.benchmark_id, self.datastream))
                    continue
                remediation_available = self._is_remediation_available(rule)

                self._check_rule(rule, remote_dir, state, remediation_available)

        if not self._matching_rule_found:
            logging.error("No matching rule ID found for '{0}'".format(target))

    def _modify_parameters(self, script, params):
        if self.scenarios_profile:
            params['profiles'] = [self.scenarios_profile]

        if not params["profiles"]:
            params["profiles"].append(OSCAP_PROFILE_ALL_ID)
            logging.debug(
                "Added the {0} profile to the list of available profiles for {1}"
                .format(OSCAP_PROFILE_ALL_ID, script))
        return params

    def _parse_parameters(self, script):
        """Parse parameters from script header"""
        params = {'profiles': [],
                  'templates': [],
                  'platform': ['multi_platform_all'],
                  'remediation': ['all']}
        with open(script, 'r') as script_file:
            script_content = script_file.read()
            for parameter in params:
                found = re.search(r'^# {0} = ([ ,_\.\-\w\(\)]*)$'.format(parameter),
                                  script_content,
                                  re.MULTILINE)
                if found is None:
                    continue
                splitted = found.group(1).split(',')
                params[parameter] = [value.strip() for value in splitted]
        return params

    def _get_scenarios(self, rule_dir, scripts, scenarios_regex, benchmark_cpes):
        """ Returns only valid scenario files, rest is ignored (is not meant
        to be executed directly.
        """

        if scenarios_regex is not None:
            scenarios_pattern = re.compile(scenarios_regex)

        scenarios = []
        for script in scripts:
            if scenarios_regex is not None:
                if scenarios_pattern.match(script) is None:
                    logging.debug("Skipping script %s - it did not match "
                                  "--scenarios regex" % script)
                    continue
            script_context = _get_script_context(script)
            if script_context is not None:
                script_params = self._parse_parameters(os.path.join(rule_dir, script))
                script_params = self._modify_parameters(script, script_params)
                if common.matches_platform(script_params["platform"], benchmark_cpes):
                    scenarios += [Scenario(script, script_context, script_params)]
                else:
                    logging.warning("Script %s is not applicable on given platform" % script)

        return scenarios

    def _check_rule(self, rule, remote_dir, state, remediation_available):
        remote_rule_dir = os.path.join(remote_dir, rule.short_id)
        logging.info(rule.id)

        logging.debug("Testing rule directory {0}".format(rule.directory))

        args_list = [
            (s, remote_rule_dir, rule.id, remediation_available)
            for s in self._get_scenarios(
                rule.directory, rule.files, self.scenarios_regex,
                self.benchmark_cpes)
        ]
        state.map_on_top(self._check_and_record_rule_scenario, args_list)

    def _check_and_record_rule_scenario(self, scenario, remote_rule_dir, rule_id, remediation_available):
        self._current_result = common.RuleResult()

        self._current_result.conditions = common.Scenario_conditions(
            self.test_env.name, self.test_env.scanning_mode,
            self.remediate_using, self.datastream)
        self._current_result.scenario = common.Scenario_run(rule_id, scenario.script)
        self._current_result.when = self.test_timestamp_str

        self._check_rule_scenario(scenario, remote_rule_dir, rule_id, remediation_available)
        self.results.append(self._current_result.save_to_dict())

    def _check_rule_scenario(self, scenario, remote_rule_dir, rule_id, remediation_available):
        if not _apply_script(
                remote_rule_dir, self.test_env.domain_ip, scenario.script):
            logging.error("Environment failed to prepare, skipping test")
            self._current_result.record_stage_result("preparation", False)
            return

        self._current_result.record_stage_result("preparation", True)
        logging.debug('Using test script {0} with context {1}'
                      .format(scenario.script, scenario.context))

        profiles = get_viable_profiles(
            scenario.script_params['profiles'], self.datastream, self.benchmark_id)
        test_data = dict(scenario=scenario,
                         rule_id=rule_id,
                         remediation_available=remediation_available)
        self.run_test_for_all_profiles(profiles, test_data)

        self.executed_tests += 1

    def finalize(self):
        super(RuleChecker, self).finalize()
        with open(os.path.join(LogHelper.LOG_DIR, "results.json"), "w") as f:
            json.dump(self.results, f)


def perform_rule_check(options):
    checker = RuleChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean
    checker.manual_debug = options.manual_debug
    checker.benchmark_cpes = options.benchmark_cpes
    checker.scenarios_regex = options.scenarios_regex

    checker.scenarios_profile = options.scenarios_profile
    # check if target is a complete profile ID, if not prepend profile prefix
    if (checker.scenarios_profile is not None and
            not checker.scenarios_profile.startswith(OSCAP_PROFILE) and
            not oscap.is_virtual_oscap_profile(checker.scenarios_profile)):
        checker.scenarios_profile = OSCAP_PROFILE+options.scenarios_profile

    checker.test_target(options.target)
