#!/bin/bash
# remediation = bash

# Use auditctl, on RHEL7, default is to use augenrules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*

# Delete everything that is between "one per line" and "one per arg"
sed '/# one per line/,/# one per arg/d' test_audit.rules > /etc/audit/audit.rules
