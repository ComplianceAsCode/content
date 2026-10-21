#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k privileged-gpasswd" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k privileged-gpasswd" >> /etc/audit/audit.rules
