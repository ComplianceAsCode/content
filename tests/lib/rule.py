#!/usr/bin/env python2
from __future__ import print_function

import sys

import lib.oscap
import lib.virt


def perform_rule_check(options):
    dom = lib.virt.connect_domain(options.hypervisor, options.domain_name)
    if dom is None:
        sys.exit(1)

    domain_ip = lib.virt.determine_ip(dom)

    snap = lib.virt.snapshot_create(dom, 'origin')
    # please update :(

    lib.virt.snapshot_revert(dom, snap)
