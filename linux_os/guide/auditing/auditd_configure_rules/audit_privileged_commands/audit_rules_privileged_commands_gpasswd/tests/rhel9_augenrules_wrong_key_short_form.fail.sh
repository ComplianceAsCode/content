#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit
# Writes the required rule shape but with a wrong audit key in the '-k' spelling, the form the RHEL 9 STIG and the old template default generate; the remediation must not treat the rule as already compliant.

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k privileged" >> /etc/audit/rules.d/identity.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k privileged" >> /etc/audit/rules.d/identity.rules
