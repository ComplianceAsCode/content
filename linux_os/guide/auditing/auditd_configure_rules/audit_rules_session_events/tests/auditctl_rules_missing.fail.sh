#!/bin/bash
# packages = audit

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
