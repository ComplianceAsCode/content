#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w /var/run/utmp -p wa" >> /etc/audit/audit.rules
echo "-w /var/log/btmp -p wa" >> /etc/audit/audit.rules
echo "-w /var/log/wtmp -p wa" >> /etc/audit/audit.rules
