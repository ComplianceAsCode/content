#!/usr/bin/env python2
from __future__ import print_function
import argparse
import logging
import os.path
import re
import shlex
import subprocess
import sys

import ssg_test_suite.virt
from ssg_test_suite.log import LogHelper

logging.getLogger(__name__).addHandler(logging.NullHandler())

_CONTEXT_RETURN_CODES = {'pass': 0,
                         'fail': 2,
                         'error': 1,
                         'notapplicable': 0,
                         'fixed': 0}

_ANSIBLE_TEMPLATE = 'urn:xccdf:fix:script:ansible'


def run_cmd(command, verbose_path):
    logging.debug('Running {}'.format(command))
    returncode = 0
    output = ""
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(shlex.split(command),
                                             stderr=verbose_file)
    except subprocess.CalledProcessError, e:
        returncode = e.returncode
        output = e.output
    return returncode, output


def run_cmd_remote(command, domain_ip, verbose_path):
    machine = 'root@{0}'.format(domain_ip)
    remote_cmd = 'ssh {0} {1}'.format(machine, command)
    logging.debug('Running {}'.format(remote_cmd))
    returncode = 0
    output = ""
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(shlex.split(remote_cmd),
                                             stderr=verbose_file)
    except subprocess.CalledProcessError, e:
        returncode = e.returncode
        output = e.output
    return returncode, output


def send_files_remote(verbose_path, remote_dir, domain_ip, *files):
    """Upload files to VM."""
    # files is a list of absolute paths on the host
    success = True
    machine = 'root@{0}'.format(domain_ip)
    logging.debug('Uploading files {0} to {1}'.format(' '.join(files),
                                                      machine))
    command = 'scp {0} {1}:{2}'.format(' '.join(files),
                                       machine,
                                       remote_dir)
    if run_cmd(command, verbose_path)[0] != 0:
        logging.error('Failed to upload files {0}'.format(' '.join(files)))
        success = False
    return success


def get_file_remote(verbose_path, local_dir, domain_ip, remote_path):
    """Download a file from VM."""
    # remote_path is an absolute path of a file on remote machine
    success = True
    machine = 'root@{0}'.format(domain_ip)
    logging.debug('Downloading file {0}:{1} to {2}'.format(machine,
                                                           remote_path,
                                                           local_dir))
    command = 'scp {0}:{1} {2}'.format(machine, remote_path, local_dir)
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


def run_stage_remediation_ansible(run_type, formatting, verbose_path):
    """Sends ARF results file (generated in the initial stage) to the remote
       machine, generates fix in form of the Ansible playbook from it (done on
       the remote machine) and then downloads the generated playbook file back
       to the host machine. Playbook is then applied to the remote machine.

       Returns False on error, or True in case of successful Ansible playbook
       run."""
    if run_type == 'rule':
        command = 'oscap info {}'.format(formatting['arf'])
        returncode, output = run_cmd(command, verbose_path)
        if returncode != 0:
            return False
        res_id = find_result_id_in_output(output)
        if res_id is None:
            logging.error(('Failed to find result ID in '
                           '{0}').format(formatting['arf']))
            return False
        formatting['result_id'] = '--result-id {}'.format(res_id)
    else:
        formatting['result_id'] = ''

    if not send_files_remote(verbose_path, '/', formatting['domain_ip'],
                             formatting['arf']):
        return False
    if run_cmd_remote(('oscap xccdf generate fix '
                       '--benchmark-id {benchmark_id} '
                       '--profile {profile} '
                       '{result_id} '
                       '--template {ansible_template} '
                       '--output /{playbook_file} '
                       '/{arf_file}').format(**formatting),
                      formatting['domain_ip'],
                      verbose_path)[0] != 0:
        return False
    if not get_file_remote(verbose_path, LogHelper.LOG_DIR,
                           formatting['domain_ip'],
                           '/' + formatting['playbook_file']):
        return False
    ansible_playbook_set_hosts(formatting['playbook'])
    command = ('ansible-playbook -i {domain_ip}, -u root '
               '{playbook}').format(**formatting)
    returncode, output = run_cmd(command, verbose_path)
    # Appends output of ansible-playbook to the verbose_path file.
    with open(verbose_path, 'a') as f:
        f.write('Stdout of "{}":'.format(command))
        f.write(output)
    if returncode != 0:
        LogHelper.preload_log(logging.ERROR,
                              ('Ansible playbook remediation run has '
                               'exited with return code {} instead of '
                               'expected 0').format(returncode),
                              'fail')
        return False
    return True


def run_profile(domain_ip,
                profile,
                stage,
                datastream,
                benchmark_id,
                remediation=False,
                ansible=False):
    """Run `oscap-ssh` command with provided parameters to check given profile.
    Log output into LogHelper.LOG_DIR.

    Return True if command ends with exit codes 0 or 2 for bash remediations or
    with 0 for Ansible remediations, otherwise return False.
    """

    formatting = {'domain_ip': domain_ip,
                  'profile': profile,
                  'datastream': datastream,
                  'benchmark_id': benchmark_id
                  }

    formatting['rem'] = "--remediate" if remediation else ""

    report_path = os.path.join(LogHelper.LOG_DIR, '{0}-{1}'.format(profile,
                                                                   stage))
    verbose_path = os.path.join(LogHelper.LOG_DIR, '{0}-{1}'.format(profile,
                                                                    stage))
    arf_file = '{0}-initial-arf.xml'.format(profile)
    arf_path = os.path.join(LogHelper.LOG_DIR, arf_file)

    formatting['report'] = LogHelper.find_name(report_path, '.html')
    verbose_path = LogHelper.find_name(verbose_path, '.verbose.log')

    if stage is 'initial' and ansible:
        formatting['arf'] = "--results-arf {}".format(arf_path)
    else:
        formatting['arf'] = ""

    if stage is 'remediation' and ansible:
        formatting['arf'] = arf_path
        formatting['arf_file'] = arf_file
        formatting['ansible_template'] = _ANSIBLE_TEMPLATE
        formatting['playbook_file'] = '{0}.yml'.format(profile)
        formatting['playbook'] = os.path.join(LogHelper.LOG_DIR,
                                              formatting['playbook_file'])
        return run_stage_remediation_ansible('profile', formatting,
                                             verbose_path)
    else:
        command = ('oscap-ssh root@{domain_ip} 22 xccdf eval '
                   '--benchmark-id {benchmark_id} '
                   '--profile {profile} '
                   '--progress --oval-results '
                   '--report {report} '
                   '--verbose DEVEL '
                   '{arf} '
                   '{rem} '
                   '{datastream}').format(**formatting)
        returncode = run_cmd(command, verbose_path)[0]
        if returncode not in [0, 2]:
            logging.error(('Profile run should end with return code 0 or 2 '
                           'not "{0}" as it did!').format(returncode))
            return False
        return True


def run_rule(domain_ip,
             profile,
             stage,
             datastream,
             benchmark_id,
             rule_id,
             context,
             script_name,
             remediation=False,
             ansible=False,
             dont_clean=False):
    """Run `oscap-ssh` command with provided parameters to check given rule,
    utilizing --rule option. Log output to LogHelper.LOG_DIR directory.

    Return True if result is as expected by context parameter. Check both
    exit code and output message.
    """

    formatting = {'domain_ip': domain_ip,
                  'profile': profile,
                  'datastream': datastream,
                  'benchmark_id': benchmark_id,
                  'rule_id': rule_id
                  }

    formatting['rem'] = "--remediate" if remediation else ""

    report_path = os.path.join(LogHelper.LOG_DIR,
                               '{0}-{1}-{2}'.format(rule_id,
                                                    script_name,
                                                    stage))
    verbose_path = os.path.join(LogHelper.LOG_DIR,
                                '{0}-{1}-{2}'.format(rule_id,
                                                     script_name,
                                                     stage))
    arf_file = '{0}-initial-arf.xml'.format(rule_id)
    arf_path = os.path.join(LogHelper.LOG_DIR, arf_file)

    verbose_path = LogHelper.find_name(verbose_path, '.verbose.log')

    if stage is 'initial' and ansible:
        formatting['arf'] = "--results-arf {}".format(arf_path)
    else:
        formatting['arf'] = ""

    success = True
    if stage is 'remediation' and ansible:
        formatting['arf'] = arf_path
        formatting['arf_file'] = arf_file
        formatting['ansible_template'] = _ANSIBLE_TEMPLATE
        formatting['playbook_file'] = '{0}.yml'.format(rule_id)
        formatting['playbook'] = os.path.join(LogHelper.LOG_DIR,
                                              formatting['playbook_file'])
        if not run_stage_remediation_ansible('rule', formatting, verbose_path):
            success = False
    else:
        expected_return_code = _CONTEXT_RETURN_CODES[context]
        formatting['report'] = LogHelper.find_name(report_path, '.html')
        command = ('oscap-ssh root@{domain_ip} 22 xccdf eval '
                   '--benchmark-id {benchmark_id} '
                   '--profile {profile} '
                   '--progress --oval-results '
                   '--rule {rule_id} '
                   '--report {report} '
                   '--verbose DEVEL '
                   '{arf} '
                   '{rem} '
                   '{datastream}').format(**formatting)
        returncode, output = run_cmd(command, verbose_path)
        if returncode != expected_return_code:
            LogHelper.preload_log(logging.ERROR,
                                  ('Scan has exited with return code {0}, '
                                   'instead of expected {1} during '
                                   'stage {2}').format(returncode,
                                                       expected_return_code,
                                                       stage),
                                  'fail')
            success = False

        # check expected result
        actual_results = re.findall('{0}:(.*)$'.format(rule_id),
                                    output,
                                    re.MULTILINE)
        if actual_results:
            if context not in actual_results:
                LogHelper.preload_log(logging.ERROR,
                                      ('Rule result should have been '
                                       '"{0}", but is "{1}"!'
                                       ).format(context,
                                                ', '.join(actual_results)),
                                      'fail')
                success = False
        else:
            LogHelper.preload_log(logging.ERROR,
                                  ('Rule {0} has not been '
                                   'evaluated! Wrong profile '
                                   'selected?').format(rule_id),
                                  'fail')
            success = False

        if success and not dont_clean:
            # to save space, we are going to remove the report
            # as we have not encountered any anomalies
            os.remove(formatting['report'])

    if success:
        LogHelper.log_preloaded('pass')
    else:
        LogHelper.log_preloaded('fail')

    return success
