#!/usr/bin/env python2
from __future__ import print_function

import argparse
import logging
import os
import os.path
import time
import sys

from ssg_test_suite.log import LogHelper
import ssg_test_suite.oscap
import ssg_test_suite.virt
import ssg_test_suite.profile
import ssg_test_suite.rule
from ssg_test_suite import xml_operations


parser = argparse.ArgumentParser()

common_parser = argparse.ArgumentParser(add_help=False)
common_parser.add_argument("--hypervisor",
                           dest="hypervisor",
                           metavar="HYPERVISOR",
                           default="qemu:///session",
                           help="libvirt hypervisor")
common_parser.add_argument("--domain",
                           dest="domain_name",
                           metavar="DOMAIN",
                           required=True,
                           help=("Specify libvirt domain to be used as a test "
                                 "bed. This domain will get remediations "
                                 "applied in it, possibly making system "
                                 "unusable for a moment. Snapshot will be "
                                 "reverted immediately afterwards. "
                                 "Domain will be returned without changes"))
common_parser.add_argument("--datastream",
                           dest="datastream",
                           metavar="DATASTREAM",
                           required=True,
                           help=("Path to the Source DataStream on this "
                                 "machine which is going to be tested"))
common_parser.add_argument("--xccdf-id",
                           dest="xccdf_id",
                           metavar="REF-ID",
                           required=True,
                           help="Reference ID related to benchmark to be used."
                                " Get one using 'oscap info <datastream>'.")
common_parser.add_argument("--loglevel",
                           dest="loglevel",
                           metavar="LOGLEVEL",
                           default="INFO",
                           help="Default level of console output")
common_parser.add_argument("--logdir",
                           dest="logdir",
                           metavar="LOGDIR",
                           default=None,
                           help="Directory to which all output is saved")

common_parser.add_argument(
    "--remediate-using",
    dest="remediate_using",
    default="oscap",
    choices=ssg_test_suite.oscap.REMEDIATION_RULE_RUNNERS.keys(),
    help="What type of remediations to use - openscap online one, "
    "or remediation done by using remediation roles "
    "that are saved to disk beforehand.")

subparsers = parser.add_subparsers(dest='subparser_name',
                                   help='Subcommands: profile, rule')

parser_profile = subparsers.add_parser('profile',
                                       help=('Testing profile-based '
                                             'remediation applied on already '
                                             'installed machine'),
                                       parents=[common_parser])
parser_profile.set_defaults(func=ssg_test_suite.profile.perform_profile_check)
parser_rule = subparsers.add_parser('rule',
                                    help=('Testing remediations of particular '
                                          'rule for various situations - '
                                          'currently not supported '
                                          'by openscap!'),
                                    parents=[common_parser])
parser_rule.set_defaults(func=ssg_test_suite.rule.perform_rule_check)

parser_profile.add_argument("target",
                            nargs="+",
                            metavar="DSPROFILE",
                            help=("Profiles to be tested, 'ALL' means every "
                                  "profile of particular benchmark will be "
                                  "evaluated."))

parser_rule.add_argument("target",
                         nargs="+",
                         metavar="RULE",
                         help=("Rule to be tested, 'ALL' means every "
                               "rule-testing scenario will be evaluated. Each "
                               "target is handled as a substring - so you can "
                               "ask for subset of all rules this way. (If you "
                               "type ipv6 as a target, all rules containing "
                               "ipv6 within id will be performed."))
parser_rule.add_argument("--dontclean",
                         dest="dont_clean",
                         action="store_true",
                         help="Do not remove html reports of successful runs")

options = parser.parse_args()

log = logging.getLogger()
# this is general logger level - needs to be
# debug otherwise it cuts silently everything
log.setLevel(logging.DEBUG)

try:
    bench_id = xml_operations.infer_benchmark_id_from_component_ref_id(
        options.datastream, options.xccdf_id)
    options.benchmark_id = bench_id
except RuntimeError as exc:
    msg = "Error inferring benchmark ID: {}".format(str(exc))
    logging.error(msg)
    sys.exit(1)


LogHelper.add_console_logger(log, options.loglevel)
# logging dir needs to be created based on other options
# thus we have to postprocess it
if 'ALL' in options.target:
    options.target = ['ALL']
if options.logdir is None:
    # default!
    prefix = options.subparser_name
    body = ""
    if 'ALL' in options.target:
        body = 'ALL'
    else:
        body = 'custom'

    date_string = time.strftime('%Y-%m-%d-%H%M', time.localtime())
    logging_dir = os.path.join(os.getcwd(),
                               'logs',
                               '{0}-{1}-{2}'.format(prefix,
                                                    body,
                                                    date_string))
    logging_dir = LogHelper.find_name(logging_dir)
else:
    logging_dir = LogHelper.find_name(options.logdir)
LogHelper.add_logging_dir(log, logging_dir)

options.func(options)
