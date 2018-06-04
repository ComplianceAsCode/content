#!/usr/bin/env python2
from __future__ import print_function

import atexit
import logging
import os
import os.path
import re
import shlex
import string
import subprocess
import sys

import ssg_test_suite.oscap as oscap
import ssg_test_suite.virt
from ssg_test_suite import xml_operations
from ssg_test_suite.virt import SnapshotStack
from ssg_test_suite.log import LogHelper
import data

logging.getLogger(__name__).addHandler(logging.NullHandler())


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
            params[parameter] = string.split(found.group(1), ', ')
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


def _send_scripts(domain_ip):
    remote_dir = './ssgts'
    archive_file = data.create_tarball('.')
    remote_archive_file = os.path.join(remote_dir, archive_file)
    machine = "root@{0}".format(domain_ip)
    logging.debug("Uploading scripts.")
    log_file_name = os.path.join(LogHelper.LOG_DIR, "data.upload.log")

    command = "ssh {0} mkdir -p {1}".format(machine, remote_dir)
    with open(log_file_name, 'a') as log_file:
        try:
            subprocess.check_call(shlex.split(command),
                                  stdout=log_file,
                                  stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            logging.error("Cannot create directoru {0}.".format(remote_dir))
            return False

    command = "scp {0} {1}:{2}".format(archive_file, machine, remote_dir)
    with open(log_file_name, 'a') as log_file:
        subprocess.check_call(shlex.split(command),
                              stdout=log_file,
                              stderr=subprocess.STDOUT)

    command = "ssh {0} tar xf {1} -C {2}".format(machine, remote_archive_file, remote_dir)
    with open(log_file_name, 'a') as log_file:
        try:
            subprocess.check_call(shlex.split(command),
                                  stdout=log_file,
                                  stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            logging.error("Cannot extract data tarball {0}.".format(remote_archive_file))
            return False
    return remote_dir


def _apply_script(rule_dir, domain_ip, script):
    """Run particular test script on VM and log it's output."""
    machine = "root@{0}".format(domain_ip)
    logging.debug("Applying script {0}".format(script))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(LogHelper.LOG_DIR,
                                 rule_name + ".prescripts.log")

    with open(log_file_name, 'a') as log_file:
        log_file.write('##### {0} / {1} #####\n'.format(rule_name, script))

    command = "ssh {0} cd {1}; bash -x {2}".format(machine, rule_dir, script)
    with open(log_file_name, 'a') as log_file:
        try:
            subprocess.check_call(shlex.split(command),
                                  stdout=log_file,
                                  stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            logging.error(("Rule testing script {0} "
                           "failed with exit code {1}").format(script,
                                                               e.returncode))
            return False
    return True


def _get_script_context(script):
    """Return context of the script."""
    result = re.search('.*\.([^.]*)\.[^.]*$', script)
    if result is None:
        return None
    return result.group(1)


def perform_rule_check(options):
    """Perform rule check.

    Iterate over rule-testing scenarios and utilize `oscap-ssh` to test every
    scenario. Expected result is encoded in scenario file name. In case of
    `fail` or `error` results expected, continue with remediation and
    reevaluation. Revert system to clean state using snapshots.

    Return value not defined, textual output and generated reports is the
    result.
    """
    dom = ssg_test_suite.virt.connect_domain(options.hypervisor,
                                             options.domain_name)
    if dom is None:
        sys.exit(1)
    snapshot_stack = SnapshotStack(dom)
    atexit.register(snapshot_stack.clear)

    snapshot_stack.create('origin')
    ssg_test_suite.virt.start_domain(dom)
    domain_ip = ssg_test_suite.virt.determine_ip(dom)
    scanned_something = False

    remote_dir = _send_scripts(domain_ip)
    if not remote_dir:
        return

    for rule_dir, rule, scripts in data.iterate_over_rules():
        if 'ALL' in options.target:
            # we want to have them all
            pass
        else:
            perform = False
            for target in options.target:
                if target in rule_dir:
                    perform = True
                    break
            if not perform:
                continue
        logging.info(rule)
        scanned_something = True
        logging.debug("Testing rule directory {0}".format(rule_dir))
        # get list of helper scripts (non-standard name)
        # and scenario scripts
        scenarios = []
        for script in scripts:
            script_context = _get_script_context(script)
            if script_context is not None:
                scenarios += [script]

        for script in scenarios:
            script_context = _get_script_context(script)
            logging.debug(('Using test script {0} '
                           'with context {1}').format(script, script_context))
            snapshot_stack.create('script')
            script_path = os.path.join(data.DATA_DIR, rule_dir, script)
            remote_rule_dir = os.path.join(remote_dir, rule_dir)

            if not _apply_script(remote_rule_dir, domain_ip, script):
                logging.error("Environment failed to prepare, skipping test")
                snapshot_stack.revert()
                continue
            script_params = _parse_parameters(script_path)
            has_worked = False
            profiles = get_viable_profiles(script_params['profiles'],
                                           options.datastream,
                                           options.benchmark_id)
            if len(profiles) > 1:
                snapshot_stack.create('profile')
            for profile in profiles:
                LogHelper.preload_log(logging.INFO,
                                      ("Script {0} "
                                       "using profile {1} "
                                       "OK").format(script,
                                                    profile),
                                      log_target='pass')
                LogHelper.preload_log(logging.ERROR,
                                      ("Script {0} "
                                       "using profile {1} "
                                       "found issue:").format(script,
                                                              profile),
                                      log_target='fail')
                has_worked = True
                run_rule_checks(
                    domain_ip, profile, options.datastream,
                    options.benchmark_id, rule, script_context,
                    script, script_params, options.remediate_using,
                    options.dont_clean,
                )
                snapshot_stack.revert(delete=False)
            if not has_worked:
                logging.error("Nothing has been tested!")
            snapshot_stack.delete()
            if len(profiles) > 1:
                snapshot_stack.revert()
    if not scanned_something:
        logging.error("Rule {0} has not been found".format(options.target))


def run_rule_checks(
        domain_ip, profile, datastream, benchmark_id, rule,
        script_context, script_name, script_params, runner, dont_clean):
    def oscap_run_rule(stage, context):
        return oscap.run_rule(
            domain_ip=domain_ip,
            profile=profile,
            stage=stage,
            datastream=datastream,
            benchmark_id=benchmark_id,
            rule_id=rule,
            context=context,
            script_name=script_name,
            runner=runner,
            dont_clean=dont_clean)

    success = oscap_run_rule('initial', script_context)
    if not success:
        msg = ("The initial scan failed for rule '{}'."
               .format(rule))
        logging.error(msg)
        return False

    is_supported = set(['all'])
    is_supported.add(
        oscap.REMEDIATION_RUNNER_TO_REMEDIATION_MEANS[runner])
    supported_and_available_remediations = set(
        script_params['remediation']).intersection(is_supported)

    if (script_context not in ['fail', 'error'] or
            len(supported_and_available_remediations) == 0):
        return success

    success = oscap_run_rule('remediation', 'fixed')
    if not success:
        msg = ("The remediation failed for rule '{}'."
               .format(rule))
        logging.error(msg)
        return success

    success = oscap_run_rule('final', 'pass')
    if not success:
        msg = ("The check after remediation failed for rule '{}'."
               .format(rule))
        logging.error(msg)
    return success
