#!/usr/bin/env python2
from __future__ import print_function

import atexit
import logging
import sys
import xml.etree.cElementTree as ET

import ssg_test_suite.oscap
import ssg_test_suite.virt
from ssg_test_suite.rule import get_viable_profiles
from ssg_test_suite.virt import SnapshotStack

logging.getLogger(__name__).addHandler(logging.NullHandler())


def perform_profile_check(options):
    """Perform profile check.

    Iterate over profiles in datastream and perform scanning of unaltered VM
    using every profile according to input. Also perform remediation run.

    Return value not defined, textual output and generated reports is the
    result.
    """
    dom = ssg_test_suite.virt.connect_domain(options.hypervisor,
                                             options.domain_name)
    if dom is None:
        sys.exit(1)
    snapshot_stack = SnapshotStack(dom)
    atexit.register(snapshot_stack.clear)

    snapshot_stack.create('origin')
    ssg_test_suite.virt.start_domain(dom)
    domain_ip = ssg_test_suite.virt.determine_ip(dom)

    has_worked = False
    profiles = get_viable_profiles(options.target,
                                   options.datastream,
                                   options.benchmark_id)
    if len(profiles) > 1:
        snapshot_stack.create('profile')
    for profile in profiles:
        logging.info("Evaluation of profile {0}.".format(profile))
        has_worked = True
        ssg_test_suite.oscap.run_profile(domain_ip,
                                         profile,
                                         'initial',
                                         options.datastream,
                                         options.benchmark_id)
        ssg_test_suite.oscap.run_profile(domain_ip,
                                         profile,
                                         'remediation',
                                         options.datastream,
                                         options.benchmark_id,
                                         remediation=True)
        ssg_test_suite.oscap.run_profile(domain_ip,
                                         profile,
                                         'final',
                                         options.datastream,
                                         options.benchmark_id)
        snapshot_stack.revert(delete=False)
    if not has_worked:
        logging.error("Nothing has been tested!")
    snapshot_stack.delete()
    # depending on number of profiles we have either "origin" snapshot
    # still to be reverted (multiple profiles) or we are reverted
    # completely (only one profile was run)
