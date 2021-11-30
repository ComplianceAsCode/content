#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

echo "-w /sbin/something -p x -k modules" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
