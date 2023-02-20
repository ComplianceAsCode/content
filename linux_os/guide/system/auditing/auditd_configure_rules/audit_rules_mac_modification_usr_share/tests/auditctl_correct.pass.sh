#!/bin/bash
# packages = audit

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-w /usr/share/selinux/ -p wa -k MAC-policy" > /etc/audit/audit.rules
