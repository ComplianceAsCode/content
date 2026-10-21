#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -F path=/usr/bin/gpasswd -F perm=x -F key=identity" >> /etc/audit/rules.d/identity.rules
echo "-a always,exit -F arch=b64 -F path=/usr/bin/gpasswd -F perm=x -F key=identity" >> /etc/audit/rules.d/identity.rules
