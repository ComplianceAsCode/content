#!/bin/bash
# packages = audit

echo "-w $path -p wra -k logins" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
