#!/bin/bash
# packages = audit

echo "-w /sbin/modprobe -p x" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
