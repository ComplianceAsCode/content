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
import xml.etree.cElementTree as ET

import ssgts.oscap
import ssgts.virt
from ssgts.log import log
from data import iterate_over_rules

NS= {'xccdf':"http://checklists.nist.gov/xccdf/1.2"}

def parse_parameters(script):
    params = {}
    with open(script, 'r') as script_file:
        for parameter in ['profiles', 'templates']:
            found = re.search('^# {0} = ([ ,_\.\-\w]*)$'.format(parameter),
                              script_file.read(),
                              re.MULTILINE)
            if found is None:
                continue
            params[parameter] = string.split(found.group(1), ', ')
    return params


def get_viable_profiles(scenarios_profiles, datastream, benchmark):
    valid_profiles = []
    root = ET.parse(datastream).getroot()
    benchmark_node = root.find("*//xccdf:Benchmark[@id='{0}']".format(benchmark), NS)
    if benchmark_node is None:
        log.error('Benchmark not found within DataStream')
        return []
    for ds_profile_element in benchmark_node.findall('xccdf:Profile', NS):
        ds_profile = ds_profile_element.attrib['id']
        for scen_profile in scenarios_profiles:
            if scen_profile in ds_profile:
                valid_profiles += [ds_profile]
    if not valid_profiles:
        log.error('No profile matched with "{0}"'.format(", ".join(scenarios_profiles)))
    return valid_profiles


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

    with open(log_file_name, 'a') as log_file:
        log_file.write('##### {0} / {1} #####\n'.format(rule_name, script))

    command = "ssh {0} bash -x {1}".format(machine, script_remote_path)
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
    dom = ssgts.virt.connect_domain(options.hypervisor, options.domain_name)
    if dom is None:
        sys.exit(1)
    atexit.register(ssgts.virt.snapshots.clear)

    ssgts.virt.snapshots.create('origin')
    ssgts.virt.start_domain(dom)
    domain_ip = ssgts.virt.determine_ip(dom)
    scanned_something = False
    for rule_dir, rule, scripts in iterate_over_rules():
        if options.target == 'ALL':
            # we want to have them all
            pass
        elif options.target not in rule_dir:
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
            script_context = get_script_context(script)
            log.debug(('Using test script {0} '
                       'with context {1}').format(script, script_context))
            ssgts.virt.snapshots.create('script')
            # copy all helper scripts, so scenario script can use them
            script_path = os.path.join(rule_dir, script)
            helper_paths = map(lambda x: os.path.join(rule_dir, x), helpers)
            send_scripts(rule_dir, domain_ip, script_path, *helper_paths)

            if not apply_script(rule_dir, domain_ip, script):
                log.error("Environment failed to prepare, skipping test")
            script_params = parse_parameters(script_path)
            has_worked = False
            profiles = get_viable_profiles(script_params['profiles'],
                                               options.datastream,
                                               options.benchmark_id)
            if len(profiles) > 1:
                ssgts.virt.snapshots.create('profile')
            for profile in profiles:
                ssgts.log.preload_log(logging.INFO,
                                    ("Script {0} "
                                     "using profile {1} OK").format(script,
                                                                    profile),
                                    log_target='pass')
                ssgts.log.preload_log(logging.ERROR,
                                    ("Script {0} "
                                     "using profile {1} "
                                     "found issue:").format(script,
                                                            profile),
                                    log_target='fail')
                has_worked = True
                if ssgts.oscap.run_rule(domain_ip=domain_ip,
                                      profile=profile,
                                      stage="initial",
                                      datastream=options.datastream,
                                      benchmark_id=options.benchmark_id,
                                      rule_id=rule,
                                      context=script_context,
                                      script_name=script,
                                      remediation=False,
                                      dont_clean=options.dont_clean):
                    if script_context in ['fail', 'error']:
                        ssgts.oscap.run_rule(domain_ip=domain_ip,
                                           profile=profile,
                                           stage="remediation",
                                           datastream=options.datastream,
                                           benchmark_id=options.benchmark_id,
                                           rule_id=rule,
                                           context='fixed',
                                           script_name=script,
                                           remediation=True,
                                           dont_clean=options.dont_clean)
                ssgts.virt.snapshots.revert(delete=False)
            if not has_worked:
                log.error("Nothing has been tested!")
            ssgts.virt.snapshots.delete()
            if len(profiles) > 1:
                ssgts.virt.snapshots.revert()
    if not scanned_something:
        log.error("Rule {0} has not been found".format(options.target))
