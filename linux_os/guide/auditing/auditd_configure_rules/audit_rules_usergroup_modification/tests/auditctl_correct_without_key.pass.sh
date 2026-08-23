#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /etc/group -p wa" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p wa" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p wa" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p wa" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p wa" >> /etc/audit/audit.rules
