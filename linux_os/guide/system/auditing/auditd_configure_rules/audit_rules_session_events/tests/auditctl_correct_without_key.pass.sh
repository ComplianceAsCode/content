#!/bin/bash
# packages = audit

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w /var/run/utmp -p wa" >> /etc/audit/audit.rules
echo "-w /var/log/btmp -p wa" >> /etc/audit/audit.rules
echo "-w /var/log/wtmp -p wa" >> /etc/audit/audit.rules
