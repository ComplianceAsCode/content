#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /usr/share/selinux/ -p wa -k MAC-policy" > /etc/audit/audit.rules
