#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -F path=/etc/sudoers.d -F perm=wa -F key=wrong" >> /etc/audit/rules.d/login.rules
echo "-a always,exit -F arch=b64 -F path=/etc/sudoers.d -F perm=wa -F key=wrong" >> /etc/audit/rules.d/login.rules
