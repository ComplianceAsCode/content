#!/usr/bin/env python2
from __future__ import print_function
import logging
import os.path
import re
import subprocess
import collections
import xml.etree.ElementTree
import sys
import json

from ssg_test_suite.log import LogHelper

logging.getLogger(__name__).addHandler(logging.NullHandler())

_CONTEXT_RETURN_CODES = {'pass': 0,
                         'fail': 2,
                         'error': 1,
                         'notapplicable': 0,
                         'fixed': 0}

_ANSIBLE_TEMPLATE = 'urn:xccdf:fix:script:ansible'
_BASH_TEMPLATE = 'urn:xccdf:fix:script:sh'
_XCCDF_NS = 'http://checklists.nist.gov/xccdf/1.2'


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


def run_cmd(command, verbose_path):
    command_string = ' '.join(command)
    logging.debug('Running {}'.format(command_string))
    returncode = 0
    output = ""
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(command,
                                             stderr=verbose_file)
    except subprocess.CalledProcessError as e:
        returncode = e.returncode
        output = e.output
    return returncode, output


def run_cmd_remote(command_string, domain_ip, verbose_path):
    machine = 'root@{0}'.format(domain_ip)
    remote_cmd = ['ssh', machine, command_string]
    logging.debug('Running {}'.format(command_string))
    returncode = 0
    output = ""
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(remote_cmd,
                                             stderr=verbose_file)
    except subprocess.CalledProcessError as e:
        returncode = e.returncode
        output = e.output
    return returncode, output


def send_files_remote(verbose_path, remote_dir, domain_ip, *files):
    """Upload files to VM."""
    # files is a list of absolute paths on the host
    success = True
    destination = 'root@{0}:{1}'.format(domain_ip, remote_dir)
    files_string = ' '.join(files)

    logging.debug('Uploading files {0} to {1}'.format(files_string,
                                                      destination))
    command = ['scp'] + list(files) + [destination]
    if run_cmd(command, verbose_path)[0] != 0:
        logging.error('Failed to upload files {0}'.format(files_string))
        success = False
    return success


def get_file_remote(verbose_path, local_dir, domain_ip, remote_path):
    """Download a file from VM."""
    # remote_path is an absolute path of a file on remote machine
    success = True
    source = 'root@{0}:{1}'.format(domain_ip, remote_path)
    logging.debug('Downloading file {0} to {1}'
                  .format(source, local_dir))
    command = ['scp', source, local_dir]
    if run_cmd(command, verbose_path)[0] != 0:
        logging.error('Failed to download file {0}'.format(remote_path))
        success = False
    return success


def find_result_id_in_output(output):
    match = re.search('result id.*$', output, re.IGNORECASE | re.MULTILINE)
    if match is None:
        return None
    # Return the right most word of the match which is the result id.
    return match.group(0).split()[-1]


def ansible_playbook_set_hosts(playbook):
    """Updates ansible playbok to apply to all hosts."""
    with open(playbook, 'r') as f:
        lines = f.readlines()
    lines.insert(1, ' - hosts: all\n')
    with open(playbook, 'w') as f:
        for line in lines:
            f.write(line)


def get_result_id_from_arf(arf_path, verbose_path):
    command = ['oscap', 'info', arf_path]
    command_string = ' '.join(command)
    returncode, output = run_cmd(command, verbose_path)
    if returncode != 0:
        raise RuntimeError('{0} returned {1} exit code'.
                           format(command_string, returncode))
    res_id = find_result_id_in_output(output)
    if res_id is None:
        raise RuntimeError('Failed to find result ID in {0}'
                           .format(arf_path))
    return res_id


def generate_fixes_remotely(formatting, verbose_path):
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

    command_string = ' '.join(command_base + command_options + command_operands)
    rc, stdout = run_cmd_remote(command_string,
                                formatting['domain_ip'], verbose_path)
    if rc != 0:
        msg = ('Command {0} ended with return code {1} (expected 0).'
               .format(command_string, rc))
        raise RuntimeError(msg)


def run_stage_remediation_ansible(run_type, formatting, verbose_path):
    """
       Returns False on error, or True in case of successful bash scripts
       run."""
    formatting['output_template'] = _ANSIBLE_TEMPLATE
    send_arf_to_remote_machine_and_generate_remediations_there(
        run_type, formatting, verbose_path)
    if not get_file_remote(verbose_path, LogHelper.LOG_DIR,
                           formatting['domain_ip'],
                           '/' + formatting['output_file']):
        return False
    ansible_playbook_set_hosts(formatting['playbook'])
    command = (
        'ansible-playbook',  '-i', '{0},'.format(formatting['domain_ip']),
        '-u' 'root', formatting['playbook'])
    command_string = ' '.join(command)
    returncode, output = run_cmd(command, verbose_path)
    # Appends output of ansible-playbook to the verbose_path file.
    with open(verbose_path, 'a') as f:
        f.write('Stdout of "{}":'.format(command_string))
        f.write(output)
    if returncode != 0:
        msg = (
            'Ansible playbook remediation run has '
            'exited with return code {} instead of expected 0'
            .format(returncode))
        LogHelper.preload_log(logging.ERROR, msg, 'fail')
        return False
    return True


def run_stage_remediation_bash(run_type, formatting, verbose_path):
    """
       Returns False on error, or True in case of successful Ansible playbook
       run."""
    formatting['output_template'] = _BASH_TEMPLATE
    send_arf_to_remote_machine_and_generate_remediations_there(
        run_type, formatting, verbose_path)
    if not get_file_remote(verbose_path, LogHelper.LOG_DIR,
                           formatting['domain_ip'],
                           '/' + formatting['output_file']):
        return False

    command_string = '/bin/bash /{output_file}'.format(** formatting)
    returncode, output = run_cmd_remote(
        command_string, formatting['domain_ip'], verbose_path)
    # Appends output of script execution to the verbose_path file.
    with open(verbose_path, 'a') as f:
        f.write('Stdout of "{}":'.format(command_string))
        f.write(output)
    if returncode != 0:
        msg = (
            'Bash script remediation run has exited with return code {} '
            'instead of expected 0'.format(returncode))
        LogHelper.preload_log(logging.ERROR, msg, 'fail')
        return False
    return True


def send_arf_to_remote_machine_and_generate_remediations_there(
        run_type, formatting, verbose_path):
    if run_type == 'rule':
        try:
            res_id = get_result_id_from_arf(formatting['arf'], verbose_path)
        except Exception as exc:
            logging.error(str(exc))
            return False
        formatting['result_id'] = res_id

    if not send_files_remote(
            verbose_path, '/', formatting['domain_ip'], formatting['arf']):
        return False

    try:
        generate_fixes_remotely(formatting, verbose_path)
    except Exception as exc:
        logging.error(str(exc))
        return False


class GenericRunner(object):
    def __init__(self, domain_ip, profile, datastream, benchmark_id):
        self.domain_ip = domain_ip
        self.profile = profile
        self.datastream = datastream
        self.benchmark_id = benchmark_id

        self.arf_file = ''
        self.arf_path = ''
        self.verbose_path = ''
        self.report_path = ''
        self.results_path = ''
        self.stage = 'undefined'

        self.clean_files = True
        self._filenames_to_clean_afterwards = set()

        self.command_base = []
        self.command_options = []
        self.command_operands = []

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

    def prepare_oscap_ssh_arguments(self):
        full_hostname = 'root@{}'.format(self.domain_ip)
        self.command_base.extend(
            ['oscap-ssh', full_hostname, '22', 'xccdf', 'eval'])
        self.command_options.extend([
            '--benchmark-id', self.benchmark_id,
            '--profile', self.profile,
            '--verbose', 'DEVEL',
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
        self.command_options = []
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
            for fname in self._filenames_to_clean_afterwards:
                os.remove(fname)

        if result:
            LogHelper.log_preloaded('pass')
        else:
            LogHelper.log_preloaded('fail')
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
            'domain_ip': self.domain_ip,
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

    def make_oscap_call(self):
        self.prepare_oscap_ssh_arguments()
        self._generate_report_file()
        returncode = run_cmd(self.get_command, self.verbose_path)[0]
        if returncode not in [0, 2]:
            logging.error(('Profile run should end with return code 0 or 2 '
                           'not "{0}" as it did!').format(returncode))
            return False
        return True


class RuleRunner(GenericRunner):
    def __init__(
            self, domain_ip, profile, datastream, benchmark_id,
            rule_id, context, script_name, dont_clean):
        super(RuleRunner, self).__init__(
            domain_ip, profile, datastream, benchmark_id,
        )

        self.rule_id = rule_id
        self.context = context
        self.script_name = script_name
        self.clean_files = not dont_clean

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
        self.prepare_oscap_ssh_arguments()
        self._generate_report_file()
        self.command_options.extend(
            ['--rule', self.rule_id])

        returncode, self._oscap_output = run_cmd(self.get_command, self.verbose_path)

        expected_return_code = _CONTEXT_RETURN_CODES[self.context]

        if returncode != expected_return_code:
            msg = (
                'Scan has exited with return code {0}, '
                'instead of expected {1} during stage {2}'
                .format(returncode, expected_return_code, self.stage)
            )
            LogHelper.preload_log(logging.ERROR, msg, 'fail')
            return False
        return True

    def final(self):
        success = super(RuleRunner, self).final()
        success = success and self._analyze_output_of_oscap_call()

        return success

    def _analyze_output_of_oscap_call(self):
        local_success = True
        # check expected result
        actual_results = re.findall('{0}:(.*)$'.format(self.rule_id),
                                    self._oscap_output,
                                    re.MULTILINE)
        if actual_results:
            if self.context not in actual_results:
                LogHelper.preload_log(logging.ERROR,
                                      ('Rule result should have been '
                                       '"{0}", but is "{1}"!'
                                       ).format(self.context,
                                                ', '.join(actual_results)),
                                      'fail')
                local_success = False
        else:
            msg = (
                'Rule {0} has not been evaluated! Wrong profile selected?'
                .format(self.rule_id))
            LogHelper.preload_log(logging.ERROR, msg, 'fail')
            local_success = False
        return local_success

    def _get_formatting_dict_for_remediation(self):
        fmt = super(RuleRunner, self)._get_formatting_dict_for_remediation()
        fmt['rule_id'] = self.rule_id

        return fmt


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

        return run_stage_remediation_ansible('profile', formatting, self.verbose_path)


class BashProfileRunner(ProfileRunner):
    def initial(self):
        self.command_options += ['--results-arf', self.arf_path]
        return super(BashProfileRunner, self).initial()

    def remediation(self):
        formatting = self._get_formatting_dict_for_remediation()
        formatting['output_file'] = '{0}.sh'.format(self.profile)

        return run_stage_remediation_bash('profile', formatting, self.verbose_path)


class OscapRuleRunner(RuleRunner):
    def remediation(self):
        self.command_options += ['--remediate']
        return self.make_oscap_call()


class BashRuleRunner(RuleRunner):
    def initial(self):
        self.command_options += ['--results-arf', self.arf_path]
        return super(BashRuleRunner, self).initial()

    def remediation(self):
        formatting = self._get_formatting_dict_for_remediation()
        formatting['output_file'] = '{0}.sh'.format(self.rule_id)

        success = run_stage_remediation_bash('rule', formatting, self.verbose_path)
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

        success = run_stage_remediation_ansible('rule', formatting, self.verbose_path)
        return success


def run_profile(domain_ip,
                profile,
                stage,
                datastream,
                benchmark_id,
                runner):
    """Run `oscap-ssh` command with provided parameters to check given profile.
    Log output into LogHelper.LOG_DIR.

    Return True if command ends with exit codes 0 or 2 for bash remediations or
    with 0 for Ansible remediations, otherwise return False.
    """
    runner_cls = REMEDIATION_PROFILE_RUNNERS[runner]
    runner = runner_cls(
        domain_ip, profile, datastream, benchmark_id)
    success = runner.run_stage(stage)
    return success


def run_rule(domain_ip,
             profile,
             stage,
             datastream,
             benchmark_id,
             rule_id,
             context,
             script_name,
             runner,
             dont_clean=False):
    """Run `oscap-ssh` command with provided parameters to check given rule,
    utilizing --rule option. Log output to LogHelper.LOG_DIR directory.

    Return True if result is as expected by context parameter. Check both
    exit code and output message.
    """
    runner_cls = REMEDIATION_RULE_RUNNERS[runner]
    runner = runner_cls(
        domain_ip, profile, datastream, benchmark_id,
        rule_id, context, script_name, dont_clean)
    success = runner.run_stage(stage)
    return success


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
