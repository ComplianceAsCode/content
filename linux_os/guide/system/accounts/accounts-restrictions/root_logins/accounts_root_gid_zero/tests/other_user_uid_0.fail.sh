#!/bin/bash

# Remediation doesn't fix the rule, only locks passwords
# of non-root accounts with uid 0.
# remediation = none

useradd --gid 0 root2
