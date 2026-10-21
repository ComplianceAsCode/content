#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

{{{ setup_augenrules_environment() }}}

echo "-a always,exit -F arch=b32 -F path=/etc/security/opasswd -F perm=wa -F key=wrong" >> /etc/audit/rules.d/opasswd.rules
echo "-a always,exit -F arch=b64 -F path=/etc/security/opasswd -F perm=wa -F key=wrong" >> /etc/audit/rules.d/opasswd.rules
