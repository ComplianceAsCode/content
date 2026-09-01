#!/bin/bash
# packages = audit

rm -rf /etc/audit/*
mkdir -p /etc/audit/rules.d/
touch /etc/audit/auditd.conf
echo '-a always,exit -F arch=b64 -S getuid -k test_execstartpost_2' > /etc/audit/rules.d/test_rule.rules
augenrules --load
chmod 0600 /etc/audit/audit.rules
chmod 0600 /etc/audit/auditd.conf
chmod 0600 /etc/audit/rules.d/test_rule.rules
