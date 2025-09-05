#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /etc/selinux/ -p wa" > /etc/audit/audit.rules
