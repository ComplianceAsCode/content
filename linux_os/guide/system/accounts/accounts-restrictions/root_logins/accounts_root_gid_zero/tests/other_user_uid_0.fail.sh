#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ubuntu
# Remediation doesn't fix the rule, only locks passwords
# of non-root accounts with uid 0.
# remediation = none

useradd --gid 0 root2
