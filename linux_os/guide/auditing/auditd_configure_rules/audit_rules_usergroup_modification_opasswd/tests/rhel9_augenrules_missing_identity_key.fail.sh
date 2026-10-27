#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

{{{ setup_augenrules_environment() }}}

# Remove any pre-existing rules so that leftover rules from other scenarios
# cannot make the initial scan pass
rm -f /etc/audit/rules.d/*.rules

echo "-a always,exit -F arch=b32 -F path=/etc/security/opasswd -F perm=wa -F key=wrong" >> /etc/audit/rules.d/opasswd.rules
echo "-a always,exit -F arch=b64 -F path=/etc/security/opasswd -F perm=wa -F key=wrong" >> /etc/audit/rules.d/opasswd.rules
