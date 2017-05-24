#!/usr/bin/env python2
from __future__ import print_function

import sys

import lib.oscap
import lib.virt


def performProfileCheck(options):
    dom = lib.virt.connectDomain(options.hypervisor, options.domain_name)
    if dom is None:
        sys.exit(1)

    domain_ip = lib.virt.determineIP(dom)

    snap = lib.virt.snapshotCreate(dom, 'origin')
    lib.oscap.runProfile(domain_ip, options.profile, 'initial', options.datastream)
    lib.oscap.runProfile(domain_ip, options.profile, 'remediation', options.datastream, remediation=True)
    lib.oscap.runProfile(domain_ip, options.profile, 'final', options.datastream)

    lib.virt.snapshotRevert(dom, snap)
