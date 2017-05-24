#!/usr/bin/env python2
from __future__ import print_function

import argparse
import shlex
import subprocess
import sys

import lib.virt


def runProfile(domain_ip, profile, stage, datastream, remediation=False):
    if remediation:
        rem = "--remediate"
    else:
        rem = ""
    command = shlex.split('oscap-ssh root@{0} 22 xccdf eval --profile {1} --progress --oval-results --report {1}_{2}.html {3} {4}'.format(domain_ip, profile, stage, rem, datastream))
    subprocess.call(command)
