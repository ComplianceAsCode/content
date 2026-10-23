#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/passwd -F perm=x -k privileged-passwd" >> /etc/audit/rules.d/privileged-passwd.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/passwd -F perm=x -k privileged-passwd" >> /etc/audit/rules.d/privileged-passwd.rules
