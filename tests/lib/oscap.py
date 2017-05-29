#!/usr/bin/env python2
from __future__ import print_function

import argparse
import os.path
import shlex
import subprocess
import sys

import lib.virt
from lib.log import log


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
    subprocess.call(command)
