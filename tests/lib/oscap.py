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
                        'notapplicable': 0}


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
    log.debug('Running ' + str(command))
    subprocess.call(command, stderr=subprocess.STDOUT)


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
                           '--report {report} '
                           '{rem} '
                           '{datastream}').format(**formatting))
    log.debug('Running ' + str(command))
    expected_return_code = CONTEXT_RETURN_CODES[context]
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError, e:
        if e.returncode != expected_return_code:
            log.error(('Command exited with {0}, '
                       'instead of {1}').format(e.returncode,
                                                expected_return_code))
        output = e.output
    else:
        if expected_return_code != 0:
            log.error(('Command exited with 0, '
                       'instead of {0}').format(expected_return_code))

    if (rule_id + ':' + context) in output:
        log.debug('Rule passed!')
    else:
        log.error('Rule result should be {0}!')
        print(output)
