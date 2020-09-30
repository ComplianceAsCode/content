#!/bin/bash


# Use auditctl in RHEL7
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify" >> /etc/audit/audit.rules
