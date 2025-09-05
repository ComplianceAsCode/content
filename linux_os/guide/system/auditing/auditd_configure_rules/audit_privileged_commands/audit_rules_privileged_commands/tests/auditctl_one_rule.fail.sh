#!/bin/bash
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

echo "-a always,exit -F path=/usr/bin/sudo -F auid>=1000 -F auid!=unset -k privileged" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
