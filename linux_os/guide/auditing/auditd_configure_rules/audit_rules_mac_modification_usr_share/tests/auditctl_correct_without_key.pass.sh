#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /usr/share/selinux/ -p wa" > /etc/audit/audit.rules
