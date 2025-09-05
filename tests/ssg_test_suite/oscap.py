#!/usr/bin/env python2
from __future__ import print_function

import logging
import os.path
import re
import collections
import xml.etree.ElementTree
import json
import datetime
import socket
import sys
import time

from ssg.constants import OSCAP_PROFILE_ALL_ID

from ssg_test_suite.log import LogHelper
from ssg_test_suite import test_env
from ssg_test_suite import common

from ssg.shims import input_func

# Needed for compatibility as there is no TimeoutError in python2.
if sys.version_info[0] < 3:
    TimeoutException = socket.timeout
else:
    TimeoutException = TimeoutError

logging.getLogger(__name__).addHandler(logging.NullHandler())

_CONTEXT_RETURN_CODES = {'pass': 0,
                         'fail': 2,
                         'error': 1,
                         'notapplicable': 0,
                         'fixed': 0}

_ANSIBLE_TEMPLATE = 'urn:xccdf:fix:script:ansible'
_BASH_TEMPLATE = 'urn:xccdf:fix:script:sh'
_XCCDF_NS = 'http://checklists.nist.gov/xccdf/1.2'


PROFILE_ALL_ID_SINGLE_QUOTED = False


def analysis_to_serializable(analysis):
    result = dict(analysis)
    for key, value in analysis.items():
        if type(value) == set:
            result[key] = tuple(value)
    return result


def save_analysis_to_json(analysis, output_fname):
    analysis2 = analysis_to_serializable(analysis)
    with open(output_fname, "w") as f:
        json.dump(analysis2, f)


def triage_xml_results(fname):
    tree = xml.etree.ElementTree.parse(fname)
    all_xml_results = tree.findall(".//{%s}rule-result" % _XCCDF_NS)

    triaged = collections.defaultdict(set)
    for result in list(all_xml_results):
        idref = result.get("idref")
        status = result.find("{%s}result" % _XCCDF_NS).text
        triaged[status].add(idref)

    return triaged


def send_files_remote(verbose_path, remote_dir, domain_ip, *files):
    """Upload files to VM."""
    # files is a list of absolute paths on the host
    success = True
    destination = 'root@{0}:{1}'.format(domain_ip, remote_dir)
    files_string = ' '.join(files)

    logging.debug('Uploading files {0} to {1}'.format(files_string,
                                                      destination))
    command = ['scp'] + list(common.SSH_ADDITIONAL_OPTS) + list(files) + [destination]
    if common.run_cmd_local(command, verbose_path)[0] != 0:
        logging.error('Failed to upload files {0}'.format(files_string))
        success = False
    return success


def get_file_remote(test_env, verbose_path, local_dir, remote_path):
    """Download a file from VM."""
    # remote_path is an absolute path of a file on remote machine
    success = True
    logging.debug('Downloading remote file {0} to {1}'
                  .format(remote_path, local_dir))
    with open(verbose_path, "a") as log_file:
        try:
            test_env.scp_download_file(remote_path, local_dir, log_file)
        except Exception:
            logging.error('Failed to download file {0}'.format(remote_path))
            success = False
    return success


def find_result_id_in_output(output):
    match = re.search('result id.*$', output, re.IGNORECASE | re.MULTILINE)
    if match is None:
        return None
    # Return the right most word of the match which is the result id.
    return match.group(0).split()[-1]


def get_result_id_from_arf(arf_path, verbose_path):
    command = ['oscap', 'info', arf_path]
    command_string = ' '.join(command)
    returncode, output = common.run_cmd_local(command, verbose_path)
    if returncode != 0:
        raise RuntimeError('{0} returned {1} exit code'.
                           format(command_string, returncode))
    res_id = find_result_id_in_output(output)
    if res_id is None:
        raise RuntimeError('Failed to find result ID in {0}'
                           .format(arf_path))
    return res_id


def single_quote_string(input):
    result = input
    for char in "\"'":
        result = result.replace(char, "")
    return "'{}'".format(result)


def generate_fixes_remotely(test_env, formatting, verbose_path):
    command_base = ['oscap', 'xccdf', 'generate', 'fix']
    command_options = [
        '--benchmark-id', formatting['benchmark_id'],
        '--profile', formatting['profile'],
        '--template', formatting['output_template'],
        '--output', '/{output_file}'.format(** formatting),
    ]
    command_operands = ['/{arf_file}'.format(** formatting)]
    if 'result_id' in formatting:
        command_options.extend(['--result-id', formatting['result_id']])

    command_components = command_base + command_options + command_operands
    command_string = ' '.join([single_quote_string(c) for c in command_components])
    with open(verbose_path, "a") as log_file:
        test_env.execute_ssh_command(command_string, log_file)


def run_stage_remediation_ansible(run_type, test_env, formatting, verbose_path):
    """
       Returns False on error, or True in case of successful Ansible playbook
       run."""
    formatting['output_template'] = _ANSIBLE_TEMPLATE
    send_arf_to_remote_machine_and_generate_remediations_there(
        run_type, test_env, formatting, verbose_path)
    if not get_file_remote(test_env, verbose_path, LogHelper.LOG_DIR,
                           '/' + formatting['output_file']):
        return False
    command = (
        'ansible-playbook', '-v', '-i', '{0},'.format(formatting['domain_ip']),
        '-u' 'root', '--ssh-common-args={0}'.format(' '.join(test_env.ssh_additional_options)),
        formatting['playbook'])
    command_string = ' '.join(command)
    returncode, output = common.run_cmd_local(command, verbose_path)
    # Appends output of ansible-playbook to the verbose_path file.
    with open(verbose_path, 'ab') as f:
        f.write('Stdout of "{}":'.format(command_string).encode("utf-8"))
        f.write(output.encode("utf-8"))
    if returncode != 0:
        msg = (
            'Ansible playbook remediation run has '
            'exited with return code {} instead of expected 0'
            .format(returncode))
        LogHelper.preload_log(logging.ERROR, msg, 'fail')
        return False
    return True


def run_stage_remediation_bash(run_type, test_env, formatting, verbose_path):
    """
       Returns False on error, or True in case of successful bash scripts
       run."""
    formatting['output_template'] = _BASH_TEMPLATE
    send_arf_to_remote_machine_and_generate_remediations_there(
        run_type, test_env, formatting, verbose_path)
    if not get_file_remote(test_env, verbose_path, LogHelper.LOG_DIR,
                           '/' + formatting['output_file']):
        return False

    command_string = '/bin/bash -x /{output_file}'.format(** formatting)

    with open(verbose_path, "a") as log_file:
        try:
            test_env.execute_ssh_command(command_string, log_file)
        except Exception as exc:
            msg = (
                'Bash script remediation run has exited with return code {} '
                'instead of expected 0'.format(exc.returncode))
            LogHelper.preload_log(logging.ERROR, msg, 'fail')
            return False
    return True


def send_arf_to_remote_machine_and_generate_remediations_there(
        run_type, test_env, formatting, verbose_path):
    if run_type == 'rule':
        try:
            res_id = get_result_id_from_arf(formatting['arf'], verbose_path)
        except Exception as exc:
            logging.error(str(exc))
            return False
        formatting['result_id'] = res_id

    with open(verbose_path, "a") as log_file:
        try:
            test_env.scp_upload_file(formatting["arf"], "/", log_file)
        except Exception:
            return False

    try:
        generate_fixes_remotely(test_env, formatting, verbose_path)
    except Exception as exc:
        logging.error(str(exc))
        return False


def is_virtual_oscap_profile(profile):
    """ Test if the profile belongs to the so called category virtual
        from OpenSCAP available profiles. It can be (all) or other id we
        might come up in the future, it just needs to be encapsulated
        with parenthesis for example "(custom_profile)".
    """
    if profile is not None:
        if profile == OSCAP_PROFILE_ALL_ID:
            return True
        else:
            if "(" == profile[:1] and ")" == profile[-1:]:
                return True
    return False


def process_profile_id(profile):
    # Detect if the profile is virtual and include single quotes if needed.
    if is_virtual_oscap_profile(profile):
        if PROFILE_ALL_ID_SINGLE_QUOTED:
            return "'{}'".format(profile)
        else:
            return profile
    else:
        return profile


class GenericRunner(object):
    def __init__(self, environment, profile, datastream, benchmark_id):
        self.environment = environment
        self.profile = profile
        self.datastream = datastream
        self.benchmark_id = benchmark_id

        self.arf_file = ''
        self.arf_path = ''
        self.verbose_path = ''
        self.report_path = ''
        self.results_path = ''
        self.stage = 'undefined'

        self.clean_files = False
        self.manual_debug = False
        self._filenames_to_clean_afterwards = set()

        self.command_base = []
        self.command_options = []
        self.command_operands = []
        # number of seconds to sleep after reboot of vm to let
        # the system to finish startup, there were problems with
        # temporary files created by Dracut during image generation interfering
        # with the scan
        self.time_to_finish_startup = 30

    def _make_arf_path(self):
        self.arf_file = self._get_arf_file()
        self.arf_path = os.path.join(LogHelper.LOG_DIR, self.arf_file)

    def _get_arf_file(self):
        raise NotImplementedError()

    def _make_verbose_path(self):
        verbose_file = self._get_verbose_file()
        verbose_path = os.path.join(LogHelper.LOG_DIR, verbose_file)
        self.verbose_path = LogHelper.find_name(verbose_path, '.verbose.log')

    def _get_verbose_file(self):
        raise NotImplementedError()

    def _make_report_path(self):
        report_file = self._get_report_file()
        report_path = os.path.join(LogHelper.LOG_DIR, report_file)
        self.report_path = LogHelper.find_name(report_path, '.html')

    def _get_report_file(self):
        raise NotImplementedError()

    def _make_results_path(self):
        results_file = self._get_results_file()
        results_path = os.path.join(LogHelper.LOG_DIR, results_file)
        self.results_path = LogHelper.find_name(results_path, '.xml')

    def _get_results_file(self):
        raise NotImplementedError()

    def _generate_report_file(self):
        self.command_options.extend([
            '--report', self.report_path,
        ])
        self._filenames_to_clean_afterwards.add(self.report_path)

    def _wait_for_continue(self):
        """ In case user requests to leave machine in failed state for hands
        on debugging, ask for keypress to continue."""
        input_func("Paused for manual debugging. Continue by pressing return.")

    def prepare_online_scanning_arguments(self):
        self.command_options.extend([
            '--benchmark-id', self.benchmark_id,
            '--profile', self.profile,
            '--progress', '--oval-results',
        ])
        self.command_operands.append(self.datastream)

    def run_stage(self, stage):
        self.stage = stage

        self._make_verbose_path()
        self._make_report_path()
        self._make_arf_path()
        self._make_results_path()

        self.command_base = []
        self.command_options = ['--verbose', 'DEVEL']
        self.command_operands = []

        result = None
        if stage == 'initial':
            result = self.initial()
        elif stage == 'remediation':
            result = self.remediation()
        elif stage == 'final':
            result = self.final()
        else:
            raise RuntimeError('Unknown stage: {}.'.format(stage))

        if self.clean_files:
            for fname in tuple(self._filenames_to_clean_afterwards):
                try:
                    os.remove(fname)
                except OSError:
                    logging.error(
                        "Failed to cleanup file '{0}'"
                        .format(fname))
                finally:
                    self._filenames_to_clean_afterwards.remove(fname)

        if result == 1:
            LogHelper.log_preloaded('pass')
            if self.clean_files:
                files_to_remove = [self.verbose_path]
                if stage in ['initial', 'final']:
                    files_to_remove.append(self.results_path)

                for fname in tuple(files_to_remove):
                    try:
                        if os.path.exists(fname):
                            os.remove(fname)
                    except OSError:
                        logging.error(
                            "Failed to cleanup file '{0}'"
                            .format(fname))
        elif result == 2:
            LogHelper.log_preloaded('notapplicable')
        else:
            LogHelper.log_preloaded('fail')
            if self.manual_debug:
                self._wait_for_continue()
        return result

    @property
    def get_command(self):
        return self.command_base + self.command_options + self.command_operands

    def make_oscap_call(self):
        raise NotImplementedError()

    def initial(self):
        self.command_options += ['--results', self.results_path]
        result = self.make_oscap_call()
        return result

    def remediation(self):
        raise NotImplementedError()

    def final(self):
        self.command_options += ['--results', self.results_path]
        result = self.make_oscap_call()
        return result

    def analyze(self, stage):
        triaged_results = triage_xml_results(self.results_path)
        triaged_results["stage"] = stage
        triaged_results["runner"] = self.__class__.__name__
        return triaged_results

    def _get_formatting_dict_for_remediation(self):
        formatting = {
            'domain_ip': self.environment.domain_ip,
            'profile': self.profile,
            'datastream': self.datastream,
            'benchmark_id': self.benchmark_id
        }
        formatting['arf'] = self.arf_path
        formatting['arf_file'] = self.arf_file
        return formatting


class ProfileRunner(GenericRunner):
    def _get_arf_file(self):
        return '{0}-initial-arf.xml'.format(self.profile)

    def _get_verbose_file(self):
        return '{0}-{1}'.format(self.profile, self.stage)

    def _get_report_file(self):
        return '{0}-{1}'.format(self.profile, self.stage)

    def _get_results_file(self):
        return '{0}-{1}-results'.format(self.profile, self.stage)

    def final(self):
        if self.environment.name == 'libvirt-based':
            logging.info("Rebooting domain '{0}' before final scan."
                         .format(self.environment.domain_name))
            self.environment.reboot()
            logging.info("Waiting for {0} seconds to let the system finish startup."
                         .format(self.time_to_finish_startup))
            time.sleep(self.time_to_finish_startup)
        return GenericRunner.final(self)

    def make_oscap_call(self):
        self.prepare_online_scanning_arguments()
        self._generate_report_file()
        returncode, self._oscap_output = self.environment.scan(
            self.command_options + self.command_operands, self.verbose_path)

        if returncode not in [0, 2]:
            logging.error(('Profile run should end with return code 0 or 2 '
                           'not "{0}" as it did!').format(returncode))
            return False
        return True


class RuleRunner(GenericRunner):
    def __init__(
            self, environment, profile, datastream, benchmark_id,
            rule_id, script_name, dont_clean, manual_debug):
        super(RuleRunner, self).__init__(
            environment, profile, datastream, benchmark_id,
        )

        self.rule_id = rule_id
        self.context = None
        self.script_name = script_name
        self.clean_files = not dont_clean
        self.manual_debug = manual_debug

        self._oscap_output = ''

    def _get_arf_file(self):
        return '{0}-initial-arf.xml'.format(self.rule_id)

    def _get_verbose_file(self):
        return '{0}-{1}-{2}'.format(self.rule_id, self.script_name, self.stage)

    def _get_report_file(self):
        return '{0}-{1}-{2}'.format(self.rule_id, self.script_name, self.stage)

    def _get_results_file(self):
        return '{0}-{1}-{2}-results-{3}'.format(
            self.rule_id, self.script_name, self.profile, self.stage)

    def make_oscap_call(self):
        self.prepare_online_scanning_arguments()
        self._generate_report_file()
        self.command_options.extend(
            ['--rule', self.rule_id])
        returncode, self._oscap_output = self.environment.scan(
            self.command_options + self.command_operands, self.verbose_path)

        return self._analyze_output_of_oscap_call()

    def final(self):
        success = super(RuleRunner, self).final()
        success = success and self._analyze_output_of_oscap_call()

        return success

    def _find_rule_result_in_output(self):
        # oscap --progress options outputs rule results to stdout in
        # following format:
        # xccdf_org....rule_accounts_password_minlen_login_defs:pass
        match = re.findall('{0}:(.*)$'.format(self.rule_id),
                           self._oscap_output,
                           re.MULTILINE)

        if not match:
            # When the rule is not selected, it won't match in output
            return "notselected"

        # When --remediation is executed, there will be two entries in
        # progress output, one for fail, and one for fixed, e.g.
        # xccdf_org....rule_accounts_password_minlen_login_defs:fail
        # xccdf_org....rule_accounts_password_minlen_login_defs:fixed
        # We are interested in the last one
        return match[-1]

    def _analyze_output_of_oscap_call(self):
        local_success = 1
        # check expected result
        rule_result = self._find_rule_result_in_output()

        if rule_result == "notapplicable":
            msg = (
                'Rule {0} evaluation resulted in {1}'
                .format(self.rule_id, rule_result))
            LogHelper.preload_log(logging.WARNING, msg, 'notapplicable')
            local_success = 2
            return local_success
        if rule_result != self.context:
            local_success = 0
            if rule_result == 'notselected':
                msg = (
                    'Rule {0} has not been evaluated! '
                    'Wrong profile selected in test scenario?'
                    .format(self.rule_id))
            else:
                msg = (
                    'Rule evaluation resulted in {0}, '
                    'instead of expected {1} during {2} stage '
                    .format(rule_result, self.context, self.stage)
                )
            LogHelper.preload_log(logging.ERROR, msg, 'fail')
        return local_success

    def _get_formatting_dict_for_remediation(self):
        fmt = super(RuleRunner, self)._get_formatting_dict_for_remediation()
        fmt['rule_id'] = self.rule_id

        return fmt

    def run_stage_with_context(self, stage, context):
        self.context = context
        return self.run_stage(stage)


class OscapProfileRunner(ProfileRunner):
    def remediation(self):
        self.command_options += ['--remediate']
        return self.make_oscap_call()


class AnsibleProfileRunner(ProfileRunner):
    def initial(self):
        self.command_options += ['--results-arf', self.arf_path]
        return super(AnsibleProfileRunner, self).initial()

    def remediation(self):
        formatting = self._get_formatting_dict_for_remediation()
        formatting['output_file'] = '{0}.yml'.format(self.profile)
        formatting['playbook'] = os.path.join(LogHelper.LOG_DIR,
                                              formatting['output_file'])

        return run_stage_remediation_ansible('profile', self.environment,
                                             formatting,
                                             self.verbose_path)


class BashProfileRunner(ProfileRunner):
    def initial(self):
        self.command_options += ['--results-arf', self.arf_path]
        return super(BashProfileRunner, self).initial()

    def remediation(self):
        formatting = self._get_formatting_dict_for_remediation()
        formatting['output_file'] = '{0}.sh'.format(self.profile)

        return run_stage_remediation_bash('profile', self.environment, formatting, self.verbose_path)


class OscapRuleRunner(RuleRunner):
    def remediation(self):
        self.command_options += ['--remediate']
        return self.make_oscap_call()

    def final(self):
        """ There is no need to run final scan again - result won't be different
        to what we already have in remediation step."""
        return True


class BashRuleRunner(RuleRunner):
    def initial(self):
        self.command_options += ['--results-arf', self.arf_path]
        return super(BashRuleRunner, self).initial()

    def remediation(self):

        formatting = self._get_formatting_dict_for_remediation()
        formatting['output_file'] = '{0}.sh'.format(self.rule_id)

        success = run_stage_remediation_bash('rule', self.environment, formatting, self.verbose_path)
        return success


class AnsibleRuleRunner(RuleRunner):
    def initial(self):
        self.command_options += ['--results-arf', self.arf_path]
        return super(AnsibleRuleRunner, self).initial()

    def remediation(self):
        formatting = self._get_formatting_dict_for_remediation()
        formatting['output_file'] = '{0}.yml'.format(self.rule_id)
        formatting['playbook'] = os.path.join(LogHelper.LOG_DIR,
                                              formatting['output_file'])

        success = run_stage_remediation_ansible('rule', self.environment, formatting, self.verbose_path)
        return success


class Checker(object):
    def __init__(self, test_env):
        self.test_env = test_env
        self.executed_tests = 0

        self.datastream = ""
        self.benchmark_id = ""
        self.remediate_using = ""
        self.benchmark_cpes = set()

        now = datetime.datetime.now()
        self.test_timestamp_str = now.strftime("%Y-%m-%d %H:%M")

    def test_target(self, target):
        self.start()
        try:
            self._test_target(target)
        except KeyboardInterrupt:
            logging.info("Terminating the test run due to keyboard interrupt.")
        except RuntimeError as exc:
            logging.error("Terminating due to error: {msg}.".format(msg=str(exc)))
        except TimeoutException as exc:
            logging.error("Terminating due to timeout: {msg}".format(msg=str(exc)))
        finally:
            self.finalize()

    def run_test_for_all_profiles(self, profiles, test_data=None):
        if len(profiles) > 1:
            with test_env.SavedState.create_from_environment(self.test_env, "prepared") as state:
                args_list = [(p, test_data) for p in profiles]
                state.map_on_top(self._run_test, args_list)
        elif profiles:
            self._run_test(profiles[0], test_data)

    def _test_target(self, target):
        raise NotImplementedError()

    def _run_test(self, profile, test_data):
        raise NotImplementedError()

    def start(self):
        self.executed_tests = 0

        try:
            self.test_env.start()
        except Exception as exc:
            msg = ("Failed to start test environment '{0}': {1}"
                   .format(self.test_env.name, str(exc)))
            raise RuntimeError(msg)

    def finalize(self):
        if not self.executed_tests:
            logging.error("Nothing has been tested!")

        try:
            self.test_env.finalize()
        except Exception as exc:
            msg = ("Failed to finalize test environment '{0}': {1}"
                   .format(self.test_env.name, str(exc)))
            raise RuntimeError(msg)


REMEDIATION_PROFILE_RUNNERS = {
    'oscap': OscapProfileRunner,
    'bash': BashProfileRunner,
    'ansible': AnsibleProfileRunner,
}


REMEDIATION_RULE_RUNNERS = {
    'oscap': OscapRuleRunner,
    'bash': BashRuleRunner,
    'ansible': AnsibleRuleRunner,
}


REMEDIATION_RUNNER_TO_REMEDIATION_MEANS = {
    'oscap': 'bash',
    'bash': 'bash',
    'ansible': 'ansible',
}
