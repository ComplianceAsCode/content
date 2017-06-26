#!/usr/bin/env python2
from __future__ import print_function

import argparse
import os.path
import re
import shlex
import subprocess
import sys

import lib.virt
from lib.log import log

_CONTEXT_RETURN_CODES = {'pass': 0,
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

    report_path = os.path.join(log.log_dir, '{0}-{1}'.format(profile,
                                                             stage))
    verbose_path = os.path.join(log.log_dir, '{0}-{1}'.format(profile,
                                                             stage))
    formatting['report'] = lib.log.find_name(report_path, '.html')
    verbose_path = lib.log.find_name(verbose_path, '.verbose.log')

    command = shlex.split(('oscap-ssh root@{domain_ip} 22 xccdf eval '
                           '--benchmark-id {benchmark_id} '
                           '--profile {profile} '
                           '--progress --oval-results '
                           '--report {report} '
                           '--verbose DEVEL '
                           '{rem} '
                           '{datastream}').format(**formatting))
    log.debug('Running ' + ' '.join(command))
    success = True
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(command, stderr=verbose_file)
    except subprocess.CalledProcessError, e:
        # non-zero exit code
        if e.returncode != 2:
            success = False
            log.error(('Profile run should end with return code 0 or 2 '
                       'not "{0}" as it did!').format(e.returncode))
    return success


def run_rule(domain_ip,
             profile,
             stage,
             datastream,
             benchmark_id,
             rule_id,
             context,
             script_name,
             remediation=False):

    formatting = {'domain_ip': domain_ip,
                  'profile': profile,
                  'datastream': datastream,
                  'benchmark_id': benchmark_id,
                  'rule_id': rule_id
                  }

    formatting['rem'] = "--remediate" if remediation else ""

    report_path = os.path.join(log.log_dir, '{0}-{1}-{2}'.format(rule_id,
                                                                      script_name,
                                                                      stage))
    verbose_path = os.path.join(log.log_dir, '{0}-{1}-{2}'.format(rule_id,
                                                              script_name,
                                                              stage))
    formatting['report'] = lib.log.find_name(report_path, '.html')
    verbose_path = lib.log.find_name(verbose_path, '.verbose.log')

    command = shlex.split(('oscap-ssh root@{domain_ip} 22 xccdf eval '
                           '--benchmark-id {benchmark_id} '
                           '--profile {profile} '
                           '--progress --oval-results '
                           '--rule {rule_id} '
                           '--report {report} '
                           '--verbose DEVEL '
                           '{rem} '
                           '{datastream}').format(**formatting))
    log.debug('Running ' + ' '.join(command))

    success = True
    # check expected return code
    expected_return_code = _CONTEXT_RETURN_CODES[context]
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(command, stderr=verbose_file)

    except subprocess.CalledProcessError, e:
        if e.returncode != expected_return_code:
            log.error(('Scan has exited with return code {0}, '
                       'instead of expected {1} '
                       'during stage {2}').format(e.returncode,
                                                  expected_return_code,
                                                  stage))
            success = False
        output = e.output
    else:
        # success branch - command exited with return code 0
        if expected_return_code != 0:
            log.error(('Scan has exited with return code 0, '
                       'instead of expected {0} '
                       'during stage {1}').format(expected_return_code,
                                                  stage))
            success = False

    # check expected result
    try:
        actual_results = re.findall('{0}:(.*)$'.format(rule_id),
                                    output,
                                    re.MULTILINE)
    except IndexError:
        log.error(('Rule {0} has not been '
                   'evaluated! Wrong profile selected?').format(rule_id))
        success = False
    else:
        if context in actual_results:
            # this is because of remediation runs, which reports two
            # results - error/fail or error/fixed - usually
            log.debug('Rule {0} results in expected way!'.format(rule_id))
        else:
            log.error(('Rule result should have been '
                       '"{0}", but is "{1}"!').format(context,
                                                      ', '.join(actual_results)))
            success = False

    if success:
        # to save space, we are going to remove the report
        # as we have not encountered any anomalies
        os.remove(formatting['report'])

    return success
