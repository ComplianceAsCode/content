#!/usr/bin/env python2
from __future__ import print_function

import argparse
import os.path
import shlex
import subprocess
import sys

import lib.virt
from lib.log import log

CONTEXT_RETURN_CODES = {'pass': 0,
                        'fail': 2,
                        'error': 1,
                        'notapplicable': 0,
                        'fixed': 0}


def run_profile(domain_ip,
                profile,
                stage,
                datastream,
                benchmark_id,
                remediation=False):

    formatting = {'domain_ip': domain_ip,
                  'profile': profile,
                  'datastream': datastream,
                  'benchmark_id': benchmark_id
                  }

    formatting['rem'] = "--remediate" if remediation else ""

    report_path = os.path.join(log.log_dir, '{0}.html'.format(stage))
    formatting['report'] = report_path

    command = shlex.split(('oscap-ssh root@{domain_ip} 22 xccdf eval '
                           '--benchmark-id {benchmark_id} '
                           '--profile {profile} '
                           '--progress --oval-results '
                           '--report {report} '
                           '{rem} '
                           '{datastream}').format(**formatting))
    log.debug('Running ' + ' '.join(command))
    subprocess.call(command, stderr=subprocess.STDOUT)
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError, e:
        # non-zero exit code
        if e.returncode != 2:
            log.error(('Profile run should end with return code 0 or 2 '
                       'not "{0}" as it did!').format(e.returncode))

    log.debug('Output:\n{0}'.format(output))


def run_rule(domain_ip,
             profile,
             stage,
             datastream,
             benchmark_id,
             rule_id,
             context,
             remediation=False):

    formatting = {'domain_ip': domain_ip,
                  'profile': profile,
                  'datastream': datastream,
                  'benchmark_id': benchmark_id,
                  'rule_id': rule_id
                  }

    formatting['rem'] = "--remediate" if remediation else ""

    report_path = os.path.join(log.log_dir, '{0}.html'.format(stage))
    formatting['report'] = report_path

    command = shlex.split(('oscap-ssh root@{domain_ip} 22 xccdf eval '
                           '--benchmark-id {benchmark_id} '
                           '--profile {profile} '
                           '--progress --oval-results '
                           '--rule {rule_id} '
                           '--report {report} '
                           '{rem} '
                           '{datastream}').format(**formatting))
    log.debug('Running ' + ' '.join(command))

    # check expected return code
    expected_return_code = CONTEXT_RETURN_CODES[context]
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError, e:
        if e.returncode != expected_return_code:
            log.error(('Command exited with return code {0}, '
                       'instead of expected {1}').format(e.returncode,
                                                         expected_return_code))
        output = e.output
    else:
        # success branch - command exited with return code 0
        if expected_return_code != 0:
            log.error(('Command exited with return code 0, '
                       'instead of expected {0}').format(expected_return_code))
    log.debug('Output:\n{0}'.format(output))

    # check expected result
    if (rule_id + ':' + context) in output:
        log.debug('Rule {0} behaves in expected way!'.format(rule_id))
    elif (rule_id + ':') not in output:
        log.error(('Rule {0} has not been '
                   'evaluated! Wrong profile selected?').format(rule_id))
    else:
        log.error('Rule result should be {0}!'.format(expected_return_code))
