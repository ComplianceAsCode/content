#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/audit.rules
echo "-w /var/log/btmp -p wa -k session" >> /etc/audit/audit.rules
echo "-w /var/log/wtmp -p wa -k session" >> /etc/audit/audit.rules
