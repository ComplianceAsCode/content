#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
# packages = audit
# Writes the required rule shape but with a wrong audit key in the '-k' spelling, the form the RHEL 9 STIG and the old template default generate; the remediation must not treat the rule as already compliant.

{{{ setup_auditctl_environment() }}}

# Start from a clean audit state, like the augenrules variants do
rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules


echo "-a always,exit -F path=/usr/sbin/useradd -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -k privileged" >> /etc/audit/audit.rules
