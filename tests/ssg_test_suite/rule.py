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
        logging.error('No profile matched with "{0}"'
                      .format(", ".join(selected_profiles)))
    return valid_profiles


def _run_with_stdout_logging(command, log_file):
    log_file.write(" ".join(command) + "\n")
    try:
        subprocess.check_call(command,
                              stdout=log_file,
                              stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError as e:
        return False


def _send_scripts(domain_ip):
    remote_dir = './ssgts'
    archive_file = data.create_tarball('.')
    remote_archive_file = os.path.join(remote_dir, archive_file)
    machine = "root@{0}".format(domain_ip)
    logging.debug("Uploading scripts.")
    log_file_name = os.path.join(LogHelper.LOG_DIR, "data.upload.log")

    with open(log_file_name, 'a') as log_file:
        command = ("ssh", machine, "mkdir", "-p", remote_dir)
        if not _run_with_stdout_logging(command, log_file):
            logging.error("Cannot create directory {0}.".format(remote_dir))
            return False

        command = ("scp", archive_file, "{0}:{1}".format(machine, remote_dir))
        if not _run_with_stdout_logging(command, log_file):
            logging.error("Cannot copy archive {0} to the target machine's directory {1}."
                          .format(archive_file, remote_dir))
            return False

        command = ("ssh", machine, "tar xf {0} -C {1}".format(remote_archive_file, remote_dir))
        if not _run_with_stdout_logging(command, log_file):
            logging.error("Cannot extract data tarball {0}.".format(remote_archive_file))
            return False

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

        command = ("ssh", machine, "cd {0}; bash -x {1}".format(rule_dir, script))
        try:
            subprocess.check_call(command,
                                  stdout=log_file,
                                  stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            logging.error("Rule testing script {0} failed with exit code {1}"
                          .format(script, e.returncode))
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
    def _run_test(self, profile, ** run_test_args):
        scenario = run_test_args["scenario"]
        rule_id = run_test_args["rule_id"]

        LogHelper.preload_log(
            logging.INFO, "Script {0} using profile {1} OK".format(scenario.script, profile),
            log_target='pass')
        LogHelper.preload_log(
            logging.ERROR,
            "Script {0} using profile {1} found issue:".format(scenario.script, profile),
            log_target='fail')

        runner_cls = ssg_test_suite.oscap.REMEDIATION_RULE_RUNNERS[self.remediate_using]
        runner = runner_cls(
            self.test_env.domain_ip, profile, self.datastream, self.benchmark_id,
            rule_id, scenario.script, self.dont_clean)

        success = runner.run_stage_with_context("initial", scenario.context)
        if not success:
            msg = ("The initial scan failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
            return False

        is_supported = set(['all'])
        is_supported.add(
            oscap.REMEDIATION_RUNNER_TO_REMEDIATION_MEANS[self.remediate_using])
        supported_and_available_remediations = set(
            scenario.script_params['remediation']).intersection(is_supported)

        if (scenario.context not in ['fail', 'error'] or
                len(supported_and_available_remediations) == 0):
            return success

        success = runner.run_stage_with_context('remediation', 'fixed')
        if not success:
            msg = ("The remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
            return success

        success = runner.run_stage_with_context('final', 'pass')
        if not success:
            msg = ("The check after remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _test_target(self, target):
        remote_dir = _send_scripts(self.test_env.domain_ip)
        if not remote_dir:
            msg = "Unable to upload test scripts"
            raise RuntimeError(msg)

        matching_rule_found = False
        for rule_dir, rule, scripts in data.iterate_over_rules():
            remote_rule_dir = os.path.join(remote_dir, rule_dir)
            local_rule_dir = os.path.join(data.DATA_DIR, rule_dir)
            if not _matches_target(rule_dir, target):
                continue
            logging.info(rule)
            matching_rule_found = True

            logging.debug("Testing rule directory {0}".format(rule_dir))

            for scenario in _get_scenarios(local_rule_dir, scripts):
                logging.debug('Using test script {0} with context {1}'
                              .format(scenario.script, scenario.context))
                with self.test_env.in_layer('script'):
                    if not _apply_script(
                            remote_rule_dir, self.test_env.domain_ip, scenario.script):
                        logging.error("Environment failed to prepare, skipping test")
                        continue

                    profiles = get_viable_profiles(
                        scenario.script_params['profiles'], self.datastream, self.benchmark_id)
                    self._test_by_profiles(profiles, scenario=scenario, rule_id=rule)
                self.executed_tests += 1

        if not matching_rule_found:
            logging.error("No matching rule ID found for '{0}'".format(target))


def perform_rule_check(options):
    checker = RuleChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean

    checker.test_target(options.target)
