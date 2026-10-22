#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F arch=b32 -F path=/etc/sudoers.d -F perm=wa -F key=wrong" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/etc/sudoers.d -F perm=wa -F key=wrong" >> /etc/audit/audit.rules
