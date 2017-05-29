#!/usr/bin/env python2
from __future__ import print_function

import atexit
import os
import os.path
import shlex
import subprocess
import sys

import lib.oscap
import lib.virt
from lib.log import log


DATA_DIR = os.path.join(os.path.dirname(os.path.realpath(sys.argv[0])), 'data')
RULE_PREFIX = 'xccdf_org.ssgproject.content_rule_'
GROUP_PREFIX = 'xccdf_org.ssgproject.content_group_'


def iterate_over_rules():
    for dir_name, directories, files in os.walk(DATA_DIR):
        leaf_dir = os.path.basename(dir_name)
        if leaf_dir.startswith(RULE_PREFIX):
            yield dir_name, files


def apply_script(rule_dir, script, domain_ip):
    script_remote_path = os.path.join('./', script)
    machine = "root@{0}".format(domain_ip)
    log.debug("Applying script {0}".format(script))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(log.log_dir, rule_name + ".prescripts.log")

    command = "scp {0} {1}:{2}".format(os.path.join(rule_dir, script),
                                       machine,
                                       script_remote_path)
    with open(log_file_name, 'a') as log_file:
        subprocess.check_call(shlex.split(command),
                              stdout=log_file,
                              stderr=subprocess.STDOUT)

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


def is_breaking(script):
    return '.break.' in script


def is_fixing(script):
    return '.fix.' in script


def is_library(script):
    return not (is_breaking(script) or is_fixing(script))


def perform_rule_check(options):
    dom = lib.virt.connect_domain(options.hypervisor, options.domain_name)
    if dom is None:
        sys.exit(1)
    atexit.register(lib.virt.snapshots.clear)

    lib.virt.snapshots.create('origin')
    lib.virt.start_domain(dom)
    domain_ip = lib.virt.determine_ip(dom)
    scanned_something = False
    for rule_dir, scripts in iterate_over_rules():
        rule = os.path.basename(rule_dir)
        if options.target not in [rule, 'ALL']:
            continue
        scanned_something = True
        log.debug("Testing rule directory {0}".format(rule_dir))
        for script in scripts:
            if is_library(script):
                log.debug("Skipping library script {0}".format(script))
                continue
            log.debug("Using test script {0}".format(script))
            lib.virt.snapshots.create('script')
            if not apply_script(rule_dir, script, domain_ip):
                log.error("Environment failed to prepare, skipping test")
            ###
            # oscap-ssh command with rule specified to be added
            ###
            lib.virt.snapshots.revert()
    if not scanned_something:
        log.warning("Rule {0} was not found".format(options.target))
