#!/usr/bin/env python2
from __future__ import print_function

import logging
import os
import os.path
import re
import subprocess
import collections

import ssg_test_suite.oscap as oscap
import ssg_test_suite.virt
from ssg_test_suite import xml_operations
from ssg_test_suite import test_env
from ssg_test_suite import common
from ssg_test_suite.log import LogHelper
import data

logging.getLogger(__name__).addHandler(logging.NullHandler())


Scenario = collections.namedtuple(
    "Scenario", ["script", "context", "script_params"])


def _parse_parameters(script):
    """Parse parameters from script header"""
    params = {'profiles': [],
              'templates': [],
              'remediation': ['all']}
    with open(script, 'r') as script_file:
        script_content = script_file.read()
        for parameter in params:
            found = re.search('^# {0} = ([ ,_\.\-\w]*)$'.format(parameter),
                              script_content,
                              re.MULTILINE)
            if found is None:
                continue
            params[parameter] = found.group(1).split(', ')
    return params


def get_viable_profiles(selected_profiles, datastream, benchmark):
    """Read datastream, and return set intersection of profiles of given
    benchmark and those provided in `selected_profiles` parameter.
    """

    valid_profiles = []
    all_profiles = xml_operations.get_all_profiles_in_benchmark(
        datastream, benchmark, logging)
    for ds_profile_element in all_profiles:
        ds_profile = ds_profile_element.attrib['id']
        if 'ALL' in selected_profiles:
            valid_profiles += [ds_profile]
            continue
        for sel_profile in selected_profiles:
            if ds_profile.endswith(sel_profile):
                valid_profiles += [ds_profile]
    if not valid_profiles:
        logging.error('No profile ends with "{0}"'
                      .format(", ".join(selected_profiles)))
    return valid_profiles


def _run_with_stdout_logging(command, args, log_file):
    log_file.write("{0} {1}\n".format(command, " ".join(args)))
    subprocess.check_call(
        (command,) + args, stdout=log_file, stderr=subprocess.STDOUT)


def _send_scripts(domain_ip):
    remote_dir = './ssgts'
    archive_file = data.create_tarball('.')
    remote_archive_file = os.path.join(remote_dir, archive_file)
    machine = "root@{0}".format(domain_ip)
    logging.debug("Uploading scripts.")
    log_file_name = os.path.join(LogHelper.LOG_DIR, "data.upload.log")

    with open(log_file_name, 'a') as log_file:
        args = common.IGNORE_KNOWN_HOSTS_OPTIONS + (machine, "mkdir", "-p", remote_dir)
        try:
            _run_with_stdout_logging("ssh", args, log_file)
        except Exception:
            msg = "Cannot create directory {0}.".format(remote_dir)
            logging.error(msg)
            raise RuntimeError(msg)

        args = (common.IGNORE_KNOWN_HOSTS_OPTIONS
                + (archive_file, "{0}:{1}".format(machine, remote_dir)))
        try:
            _run_with_stdout_logging("scp", args, log_file)
        except Exception:
            msg = ("Cannot copy archive {0} to the target machine's directory {1}."
                   .format(archive_file, remote_dir))
            logging.error(msg)
            raise RuntimeError(msg)

        args = (common.IGNORE_KNOWN_HOSTS_OPTIONS
                + (machine, "tar xf {0} -C {1}".format(remote_archive_file, remote_dir)))
        try:
            _run_with_stdout_logging("ssh", args, log_file)
        except Exception:
            msg = "Cannot extract data tarball {0}.".format(remote_archive_file)
            logging.error(msg)
            raise RuntimeError(msg)

    return remote_dir


def _apply_script(rule_dir, domain_ip, script):
    """Run particular test script on VM and log it's output."""
    machine = "root@{0}".format(domain_ip)
    logging.debug("Applying script {0}".format(script))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(
        LogHelper.LOG_DIR, rule_name + ".prescripts.log")

    with open(log_file_name, 'a') as log_file:
        log_file.write('##### {0} / {1} #####\n'.format(rule_name, script))

        command = "cd {0}; bash -x {1}".format(rule_dir, script)
        args = common.IGNORE_KNOWN_HOSTS_OPTIONS + (machine, command)

        try:
            _run_with_stdout_logging("ssh", args, log_file)
        except subprocess.CalledProcessError as exc:
            logging.error("Rule testing script {script} failed with exit code {rc}"
                          .format(script=script, rc=exc.returncode))
            return False
    return True


def _get_script_context(script):
    """Return context of the script."""
    result = re.search('.*\.([^.]*)\.[^.]*$', script)
    if result is None:
        return None
    return result.group(1)


def _matches_target(rule_dir, targets):
    if 'ALL' in targets:
        # we want to have them all
        return True
    else:
        for target in targets:
            if target in rule_dir:
                return True
        return False


def _get_scenarios(rule_dir, scripts):
    """ Returns only valid scenario files, rest is ignored (is not meant
    to be executed directly.
    """

    scenarios = []
    for script in scripts:
        script_context = _get_script_context(script)
        if script_context is not None:
            script_params = _parse_parameters(os.path.join(rule_dir, script))
            scenarios += [Scenario(script, script_context, script_params)]
    return scenarios


class RuleChecker(ssg_test_suite.oscap.Checker):
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

    def _run_test(self, profile, test_data):
        scenario = test_data["scenario"]
        rule_id = test_data["rule_id"]

        LogHelper.preload_log(
            logging.INFO, "Script {0} using profile {1} OK".format(scenario.script, profile),
            log_target='pass')
        LogHelper.preload_log(
            logging.ERROR,
            "Script {0} using profile {1} found issue:".format(scenario.script, profile),
            log_target='fail')

        runner_cls = ssg_test_suite.oscap.REMEDIATION_RULE_RUNNERS[self.remediate_using]
        runner = runner_cls(
            self.test_env, profile, self.datastream, self.benchmark_id,
            rule_id, scenario.script, self.dont_clean, self.manual_debug)
        if not self._initial_scan_went_ok(runner, rule_id, scenario.context):
            return False

        supported_and_available_remediations = self._get_available_remediations(scenario)
        if (scenario.context not in ['fail', 'error']
                or not supported_and_available_remediations):
            return True

        if not self._remediation_went_ok(runner, rule_id):
            return False

        return self._final_scan_went_ok(runner, rule_id)

    def _initial_scan_went_ok(self, runner, rule_id, context):
        success = runner.run_stage_with_context("initial", context)
        if not success:
            msg = ("The initial scan failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _get_available_remediations(self, scenario):
        is_supported = set(['all'])
        is_supported.add(
            oscap.REMEDIATION_RUNNER_TO_REMEDIATION_MEANS[self.remediate_using])
        supported_and_available_remediations = set(
            scenario.script_params['remediation']).intersection(is_supported)
        return supported_and_available_remediations

    def _remediation_went_ok(self, runner, rule_id):
        success = runner.run_stage_with_context('remediation', 'fixed')
        if not success:
            msg = ("The remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _final_scan_went_ok(self, runner, rule_id):
        success = runner.run_stage_with_context('final', 'pass')
        if not success:
            msg = ("The check after remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _test_target(self, target):
        try:
            remote_dir = _send_scripts(self.test_env.domain_ip)
        except RuntimeError as exc:
            msg = "Unable to upload test scripts: {more_info}".format(more_info=str(exc))
            raise RuntimeError(msg)

        self._matching_rule_found = False

        with test_env.SavedState.create_from_environment(self.test_env, "tests_uploaded") as state:
            for rule in data.iterate_over_rules():
                if not _matches_target(rule.directory, target):
                    continue
                self._matching_rule_found = True
                self._check_rule(rule, remote_dir, state)

        if not self._matching_rule_found:
            logging.error("No matching rule ID found for '{0}'".format(target))

    def _check_rule(self, rule, remote_dir, state):
        remote_rule_dir = os.path.join(remote_dir, rule.directory)
        local_rule_dir = os.path.join(data.DATA_DIR, rule.directory)

        logging.info(rule.id)

        logging.debug("Testing rule directory {0}".format(rule.directory))

        args_list = [(s, remote_rule_dir, rule.id)
                     for s in _get_scenarios(local_rule_dir, rule.files)]
        state.map_on_top(self._check_rule_scenario, args_list)

    def _check_rule_scenario(self, scenario, remote_rule_dir, rule_id):
        if not _apply_script(
                remote_rule_dir, self.test_env.domain_ip, scenario.script):
            logging.error("Environment failed to prepare, skipping test")
            return

        logging.debug('Using test script {0} with context {1}'
                      .format(scenario.script, scenario.context))

        profiles = get_viable_profiles(
            scenario.script_params['profiles'], self.datastream, self.benchmark_id)
        test_data = dict(scenario=scenario, rule_id=rule_id)
        self.run_test_for_all_profiles(profiles, test_data)

        self.executed_tests += 1


def perform_rule_check(options):
    checker = RuleChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean
    checker.manual_debug = options.manual_debug

    checker.test_target(options.target)
