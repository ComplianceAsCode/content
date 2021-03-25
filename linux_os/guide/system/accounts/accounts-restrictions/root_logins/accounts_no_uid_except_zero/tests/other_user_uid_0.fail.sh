#!/bin/bash
#
# Remediation doesn't fix the rule, only locks passwords
# of non-root accounts with uid 0.
# remediation = none

useradd --non-unique --uid 0 root2
