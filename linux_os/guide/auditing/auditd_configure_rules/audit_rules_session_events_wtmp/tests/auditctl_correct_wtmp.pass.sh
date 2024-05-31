#!/bin/bash
# packages = audit

echo "-w /var/log/wtmp -p wa -k logins" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
