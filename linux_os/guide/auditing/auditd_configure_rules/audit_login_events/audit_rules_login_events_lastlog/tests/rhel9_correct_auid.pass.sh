#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

echo "-a always,exit -F arch=b32 -F path=/var/log/lastlog -F perm=wa -F auid>=1000 -F auid!=unset -k logins" >> /etc/audit/rules.d/logins.rules
echo "-a always,exit -F arch=b64 -F path=/var/log/lastlog -F perm=wa -F auid>=1000 -F auid!=unset -k logins" >> /etc/audit/rules.d/logins.rules
