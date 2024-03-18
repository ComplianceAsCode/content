#!/bin/bash
# packages = audit

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service


rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w {{{ PATH }}} -p wa -k {{{ rule_id }}}" >> /etc/audit/audit.rules
