#!/bin/bash
# packages = audit

echo "-w {{{ PATH }}} -p wa" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
