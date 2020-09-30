#!/bin/bash
# remediation = bash

# Use auditctl, on RHEL7, default is to use augenrules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*

# Delete everything that is not between "one per line" and "multiple per arg"
sed '/# one per line/,/# multiple per arg/!d' test_audit.rules > /etc/audit/audit.rules

