#!/bin/bash
# packages = audit

echo "-w /run/utmp -p wa -k session" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
