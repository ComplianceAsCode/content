#!/bin/bash
# packages = audit

echo "-w /sbin/something -p x -k modules" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
