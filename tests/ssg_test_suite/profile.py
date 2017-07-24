#!/usr/bin/env python2
from __future__ import print_function

import atexit
import sys
import xml.etree.cElementTree as ET

from ssg_test_suite.log import log
import ssg_test_suite.oscap
import ssg_test_suite.virt

NS = {'xccdf': "http://checklists.nist.gov/xccdf/1.2"}


def get_viable_profiles(selected_profile, datastream, benchmark):
    # this is basically copy paste of function in ssg_test_suite.rule
    # TODO: code deduplication
    valid_profiles = []
    root = ET.parse(datastream).getroot()
    benchmark_node = root.find("*//xccdf:Benchmark[@id='{0}']".format(benchmark), NS)
    if benchmark_node is None:
        log.error('Benchmark not found within DataStream')
        return []
    for ds_profile_element in benchmark_node.findall('xccdf:Profile', NS):
        ds_profile = ds_profile_element.attrib['id']
        if ds_profile == selected_profile or 'ALL' == selected_profile:
            valid_profiles += [ds_profile]
    if not valid_profiles:
        log.error('No profile matched with "{0}"'.format(selected_profile))
    return valid_profiles


def perform_profile_check(options):
    dom = ssg_test_suite.virt.connect_domain(options.hypervisor,
                                             options.domain_name)
    if dom is None:
        sys.exit(1)
    atexit.register(ssg_test_suite.virt.snapshots.clear)

    ssg_test_suite.virt.snapshots.create('origin')
    ssg_test_suite.virt.start_domain(dom)
    domain_ip = ssg_test_suite.virt.determine_ip(dom)

    has_worked = False
    profiles = get_viable_profiles(options.target,
                                   options.datastream,
                                   options.benchmark_id)
    if len(profiles) > 1:
        ssg_test_suite.virt.snapshots.create('profile')
    for profile in profiles:
        log.info("Evaluation of profile {0}.".format(profile))
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
        ssg_test_suite.virt.snapshots.revert(delete=False)
    if not has_worked:
        log.error("Nothing has been tested!")
    ssg_test_suite.virt.snapshots.delete()
    # depending on number of profiles we have either "origin" snapshot
    # still to be reverted (multiple profiles) or we are reverted
    # completely (only one profile was run)
