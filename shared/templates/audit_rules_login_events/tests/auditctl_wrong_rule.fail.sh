#!/bin/bash
# packages = audit

echo "-w {{{ PATH }}} -p w -k logins" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
