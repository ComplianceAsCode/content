#!/bin/bash
# packages = audit


# Use auditctl, on RHEL7, default is to use augenrules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed -e '7,15d' -e '/.*init.*/d' test_audit.rules > /etc/audit/audit.rules
