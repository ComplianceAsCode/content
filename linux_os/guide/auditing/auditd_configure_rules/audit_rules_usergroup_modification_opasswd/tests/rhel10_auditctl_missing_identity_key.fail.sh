#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

{{{ setup_auditctl_environment() }}}

# Remove any pre-existing rules for the watched path so that leftover rules
# from other scenarios cannot make the initial scan pass
sed -i '/path=\/etc\/security\/opasswd/d' /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -F path=/etc/security/opasswd -F perm=wa -F key=wrong" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/etc/security/opasswd -F perm=wa -F key=wrong" >> /etc/audit/audit.rules
