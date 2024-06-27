#!/bin/bash
# packages = audit
# remediation = bash
# platform = Oracle Linux 7

echo "-a always,exit -F path=/usr/bin/sudo -F auid>={{{ uid_min }}} -F auid!=4294967295 -k privileged" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
