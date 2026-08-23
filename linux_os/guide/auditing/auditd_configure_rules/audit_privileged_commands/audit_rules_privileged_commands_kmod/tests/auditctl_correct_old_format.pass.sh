#!/bin/bash
# platform = multi_platform_ubuntu
# packages = audit

echo "-w /bin/kmod -p x -k privileged" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
