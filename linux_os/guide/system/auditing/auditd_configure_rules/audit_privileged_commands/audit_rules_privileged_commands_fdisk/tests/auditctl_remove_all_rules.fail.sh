#!/bin/bash
# platform = multi_platform_ubuntu
# packages = audit

rm -f /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
