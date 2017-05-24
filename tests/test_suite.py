#!/usr/bin/env python2
from __future__ import print_function

import argparse
import shlex
import subprocess
import sys

import lib.oscap
import lib.virt
import lib.profile
import lib.rule



parser = argparse.ArgumentParser()

common_parser = argparse.ArgumentParser(add_help=False)
common_parser.add_argument("--hypervisor", dest = "hypervisor",
    metavar = "qemu:///HYPERVISOR",
    default = "qemu:///session",
    help = "libvirt hypervisor",
)
common_parser.add_argument("--domain", dest = "domain_name",
    metavar = "DOMAIN",
    default = None,
    help = "libvirt domain used as test bed",
)
common_parser.add_argument("--datastream", dest = "datastream",
    metavar = "DATASTREAM",
    default = "/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml",
    help = "Source DataStream to be tested"
)
subparsers = parser.add_subparsers(help='Subcommands: profile, rule')

parser_profile = subparsers.add_parser('profile', help='Testing profile-based remediation applied on already installed machine', parents=[common_parser])
parser_profile.set_defaults(func=lib.profile.performProfileCheck)
parser_rule = subparsers.add_parser('rule', help='Testing remediations of particular rule for various situations - currently not supported by openscap!', parents=[common_parser])
parser_rule.set_defaults(func=lib.rule.performRuleCheck)

parser_profile.add_argument("--profile", dest = "profile",
    metavar = "DSPROFILE",
    default = "xccdf_org.ssgproject.content_profile_common",
    help = "Profile to be tested"
)

parser_rule.add_argument("--rule", dest = "rule",
    metavar = "RULE",
    default = None,
    help = "Rule to be tested"
)

options = parser.parse_args()
options.func(options)

