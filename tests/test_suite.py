#!/usr/bin/env python2
from __future__ import print_function

import argparse
import os
import os.path
import sys
import time

from lib.log import log
import lib.log
import lib.oscap
import lib.virt
import lib.profile
import lib.rule

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
                                 "applied in it, possibly making system unusable "
                                 "for a moment. Snapshot will be reverted "
                                 "immediately afterwards. "
                                 "Domain will be returned without changes"))
common_parser.add_argument("--datastream",
                           dest="datastream",
                           metavar="DATASTREAM",
                           default=("/usr/share/xml/scap/ssg/content/"
                                    "ssg-rhel7-ds.xml"),
                           help=("Path to the Source DataStream on this machine"
                                 " which is going to be tested"))
common_parser.add_argument("--benchmark-id",
                           dest="benchmark_id",
                           metavar="BENCHMARK",
                           default="xccdf_org.ssgproject.content_benchmark_RHEL-7",
                           help="Benchmark in the Source DataStream to be used")
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
subparsers = parser.add_subparsers(help='Subcommands: profile, rule')

parser_profile = subparsers.add_parser('profile',
                                       help=('Testing profile-based '
                                             'remediation applied on already '
                                             'installed machine'),
                                       parents=[common_parser])
parser_profile.set_defaults(func=lib.profile.perform_profile_check)
parser_rule = subparsers.add_parser('rule',
                                    help=('Testing remediations of particular '
                                          'rule for various situations - '
                                          'currently not supported '
                                          'by openscap!'),
                                    parents=[common_parser])
parser_rule.set_defaults(func=lib.rule.perform_rule_check)

parser_profile.add_argument("target",
                            nargs="?",
                            metavar="DSPROFILE",
                            default='xccdf_org.ssgproject.content_profile_common',
                            help=("Profiles to be tested, ALL means every "
                                  "profile of particular benchmark will be "
                                  "evaluated"))

parser_rule.add_argument("target",
                         nargs="?",
                         metavar="RULE",
                         default="ALL",
                         help="Rule to be tested")
parser_rule.add_argument("--dontclean",
                         dest="dont_clean",
                         action="store_true",
                         help="Do not remove html reports of successful runs")

options = parser.parse_args()
lib.log.add_console_logger(options.loglevel)
# logging dir needs to be created based on other options
# thus we have to postprocess it
if options.logdir is None:
    # default!
    date_string = time.strftime('%Y-%m-%d-%H%M', time.localtime())
    logging_dir = os.path.join(os.getcwd(),
                               'logs',
                               '{0}-{1}'.format(options.target,
                                                   date_string))
    logging_dir = lib.log.find_name(logging_dir)
else:
    logging_dir = lib.log.find_name(options.logdir)
lib.log.add_logging_dir(logging_dir)

options.func(options)
