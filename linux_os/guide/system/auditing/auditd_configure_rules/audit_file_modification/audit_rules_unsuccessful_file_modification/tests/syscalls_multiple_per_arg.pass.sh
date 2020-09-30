#!/bin/bash
# remediation = bash

# Use auditctl, on RHEL7, default is to use augenrules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*

# Deletes everything up do "one per line"
# Then deletes everything from "one per arg" until end of file
sed '/# one per line/,/# multiple per arg/d;/# one per arg/,$d' test_audit.rules > /etc/audit/audit.rules
