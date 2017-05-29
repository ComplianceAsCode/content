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
                           metavar="qemu:///HYPERVISOR",
                           default="qemu:///session",
                           help="libvirt hypervisor")
common_parser.add_argument("--domain",
                           dest="domain_name",
                           metavar="DOMAIN",
                           default=None,
                           help="libvirt domain used as test bed")
common_parser.add_argument("--datastream",
                           dest="datastream",
                           metavar="DATASTREAM",
                           default=("/usr/share/xml/scap/ssg/content/"
                                    "ssg-rhel7-ds.xml"),
                           help="Source DataStream to be tested")
common_parser.add_argument("--loglevel",
                           dest="loglevel",
                           metavar="LOGLEVEL",
                           default="WARNING",
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

parser_profile.add_argument("--profile",
                            dest="target",
                            metavar="DSPROFILE",
                            default="xccdf_org.ssgproject.content_profile_common",
                            help="Profile to be tested")

parser_rule.add_argument("--rule",
                         dest="target",
                         metavar="RULE",
                         default="ALL",
                         help="Rule to be tested")

options = parser.parse_args()
log.setLevel(options.loglevel)
# logging dir needs to be created based on other options
# thus we have to postprocess it
if options.logdir is None:
    # default!
    date_string = time.strftime('%Y-%m-%d-%H:%M', time.localtime())
    logging_dir = os.path.join(os.getcwd(),
                               'logs',
                               '{0}-{1}'.format(options.target,
                                                date_string))
    if os.path.exists(logging_dir):
        log.error("Logging directory already exists, exiting...")
        sys.exit(1)
    lib.log.add_logging_dir(logging_dir)
else:
    lib.log.add_logging_dir(options.logdir)

options.func(options)
