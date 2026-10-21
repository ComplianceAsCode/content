#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit
# Writes the rules with the '-S execve' filter the RHEL 10 checktext does not prescribe; the scan must fail and the remediation must rewrite them into the plain form.

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F arch=b32 -S execve -F path=/usr/bin/gpasswd -F perm=x -k privileged-gpasswd" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S execve -F path=/usr/bin/gpasswd -F perm=x -k privileged-gpasswd" >> /etc/audit/audit.rules
