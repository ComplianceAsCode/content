#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit
# Writes the rules with the '-S execve' filter; the RHEL 9 requirement for this command uses plain path rules without a syscall filter, so the scan must fail and the remediation must rewrite them.

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/passwd -F perm=x -k identity" >> /etc/audit/rules.d/identity.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/passwd -F perm=x -k identity" >> /etc/audit/rules.d/identity.rules
