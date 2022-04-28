#!/bin/bash
# packages = audit

echo "-w /run/something -p wa -k session" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
