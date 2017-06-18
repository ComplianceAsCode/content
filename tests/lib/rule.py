#!/usr/bin/env python2
from __future__ import print_function

import atexit
import os
import os.path
import re
import shlex
import subprocess
import sys

import lib.oscap
import lib.virt
from lib.log import log
from data import iterate_over_rules


def send_scripts(rule_dir, domain_ip, *scripts_list):
    # scripts_list is list of absolute paths
    remote_dir = './'
    machine = "root@{0}".format(domain_ip)
    log.debug("Uploading scripts {0}".format(scripts_list))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(log.log_dir, rule_name + ".upload.log")

    command = "scp {0} {1}:{2}".format(' '.join(scripts_list),
                                       machine,
                                       remote_dir)
    with open(log_file_name, 'a') as log_file:
        subprocess.check_call(shlex.split(command),
                              stdout=log_file,
                              stderr=subprocess.STDOUT)


def apply_script(rule_dir, domain_ip, script):
    script_remote_path = os.path.join('./', script)
    machine = "root@{0}".format(domain_ip)
    log.debug("Applying script {0}".format(script))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(log.log_dir, rule_name + ".prescripts.log")

    command = "ssh {0} chmod +x {1}".format(machine, script_remote_path)
    with open(log_file_name, 'a') as log_file:
        subprocess.check_call(shlex.split(command),
                              stdout=log_file,
                              stderr=subprocess.STDOUT)

    command = "ssh {0} {1}".format(machine, script_remote_path)
    with open(log_file_name, 'a') as log_file:
        try:
            subprocess.check_call(shlex.split(command),
                                  stdout=log_file,
                                  stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError, e:
            log.error(("Rule testing script {0} "
                       "failed with exit code {1}").format(script,
                                                           e.returncode))
            return False
    return True


def get_script_context(script):
    result = re.search('.*\.([^.]*)\.[^.]*$', script)
    if result is None:
        return None
    return result.group(1)


def perform_rule_check(options):
    dom = lib.virt.connect_domain(options.hypervisor, options.domain_name)
    if dom is None:
        sys.exit(1)
    atexit.register(lib.virt.snapshots.clear)

    lib.virt.snapshots.create('origin')
    lib.virt.start_domain(dom)
    domain_ip = lib.virt.determine_ip(dom)
    scanned_something = False
    for rule_dir, rule, scripts in iterate_over_rules():
        if options.target == 'ALL':
            # we want to have them all
            pass
        elif options.target not in rule:
            # we are not ALL, and not passing this criterion ... skipping
            continue
        log.info(rule)
        scanned_something = True
        log.debug("Testing rule directory {0}".format(rule_dir))
        # get list of helper scripts (non-standard name)
        # and scenario scripts
        helpers = []
        scenarios = []
        for script in scripts:
            script_context = get_script_context(script)
            if script_context is None:
                log.debug('Registering helper script {0}'.format(script))
                helpers += [script]
            else:
                scenarios += [script]

        for script in scenarios:
            log.debug(('Using test script {0} '
                       'with context {1}').format(script, script_context))
            lib.virt.snapshots.create('script')
            # copy all helper scripts, so scenario script can use them
            script_path = os.path.join(rule_dir, script)
            helper_paths = map(lambda x: os.path.join(rule_dir, x), helpers)
            send_scripts(rule_dir, domain_ip, script_path, *helper_paths)

            if not apply_script(rule_dir, domain_ip, script):
                log.error("Environment failed to prepare, skipping test")
            lib.oscap.run_rule(domain_ip=domain_ip,
                               profile=options.profile,
                               stage="initial",
                               datastream=options.datastream,
                               benchmark_id=options.benchmark_id,
                               rule_id=rule,
                               context=script_context,
                               remediation=False)
            if script_context in ['fail', 'error']:
                lib.oscap.run_rule(domain_ip=domain_ip,
                                   profile=options.profile,
                                   stage="remediation",
                                   datastream=options.datastream,
                                   benchmark_id=options.benchmark_id,
                                   rule_id=rule,
                                   context='fixed',
                                   remediation=True)
                lib.oscap.run_rule(domain_ip=domain_ip,
                                   profile=options.profile,
                                   stage="final",
                                   datastream=options.datastream,
                                   benchmark_id=options.benchmark_id,
                                   rule_id=rule,
                                   context='pass',
                                   remediation=False)
            lib.virt.snapshots.revert()
    if not scanned_something:
        log.error("Rule {0} was not found".format(options.target))
