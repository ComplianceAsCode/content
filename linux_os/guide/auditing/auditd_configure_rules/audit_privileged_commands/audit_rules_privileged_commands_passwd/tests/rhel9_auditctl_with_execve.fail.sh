#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/passwd -F perm=x -k identity" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/passwd -F perm=x -k identity" >> /etc/audit/audit.rules
