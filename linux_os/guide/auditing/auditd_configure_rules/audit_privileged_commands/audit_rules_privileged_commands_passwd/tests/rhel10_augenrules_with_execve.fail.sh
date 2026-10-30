#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit
# Writes the rules with the '-S execve' filter, the shape the RHEL 9 STIG prescribes; the RHEL 10 required rules have no syscall filter, so the scan must fail and the remediation must rewrite them into the plain form (the RHEL 9 to RHEL 10 upgrade case).

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/passwd -F perm=x -k privileged-passwd" >> /etc/audit/rules.d/privileged-passwd.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/passwd -F perm=x -k privileged-passwd" >> /etc/audit/rules.d/privileged-passwd.rules
