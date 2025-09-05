#!/bin/bash


# Use auditctl, on RHEL7, default is to use augenrules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '1,10d' test_audit.rules > /etc/audit/audit.rules
sed -i '5,8d' /etc/audit/audit.rules
