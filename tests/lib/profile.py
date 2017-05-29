#!/usr/bin/env python2
from __future__ import print_function

import atexit
import sys

import lib.oscap
import lib.virt


def perform_profile_check(options):
    dom = lib.virt.connect_domain(options.hypervisor, options.domain_name)
    if dom is None:
        sys.exit(1)
    atexit.register(lib.virt.snapshots.clear)

    lib.virt.snapshots.create('origin')
    lib.virt.start_domain(dom)
    domain_ip = lib.virt.determine_ip(dom)

    lib.oscap.run_profile(domain_ip,
                          options.target,
                          'initial',
                          options.datastream)
    lib.oscap.run_profile(domain_ip,
                          options.target,
                          'remediation',
                          options.datastream,
                          remediation=True)
    lib.oscap.run_profile(domain_ip,
                          options.target,
                          'final',
                          options.datastream)
