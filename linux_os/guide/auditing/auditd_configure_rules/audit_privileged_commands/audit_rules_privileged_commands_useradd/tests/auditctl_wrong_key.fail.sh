#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit
# Writes the required rule shape but with a wrong audit key in the '-F key' spelling; the scan must fail and the remediation must write the rules with the required key.

{{{ setup_auditctl_environment() }}}

# Start from a clean audit state, like the augenrules variants do
rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules


echo "-a always,exit -F path=/usr/sbin/useradd -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=wrong" >> /etc/audit/audit.rules
