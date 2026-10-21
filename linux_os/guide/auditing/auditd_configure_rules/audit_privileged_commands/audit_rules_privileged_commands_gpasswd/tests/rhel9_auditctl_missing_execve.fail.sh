#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F arch=b32 -F path=/usr/bin/gpasswd -F perm=x -F key=identity" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/usr/bin/gpasswd -F perm=x -F key=identity" >> /etc/audit/audit.rules
