#!/bin/bash
# packages = audit

echo "-w /var/log/btmp -p wa" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
