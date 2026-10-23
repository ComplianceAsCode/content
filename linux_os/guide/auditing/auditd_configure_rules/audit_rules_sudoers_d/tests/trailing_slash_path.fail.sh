#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

# The RHEL 10 rules must watch /etc/sudoers.d without the trailing slash.
echo "-a always,exit -F arch=b32 -F path=/etc/sudoers.d/ -F perm=wa -F key=identity" >> /etc/audit/rules.d/login.rules
echo "-a always,exit -F arch=b64 -F path=/etc/sudoers.d/ -F perm=wa -F key=identity" >> /etc/audit/rules.d/login.rules
