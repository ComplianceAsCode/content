#!/bin/bash
# packages = audit

rm -rf /etc/audit/*
mkdir -p /etc/audit/rules.d/
export TESTFILE=/etc/audit/rules.d/test_rule.rules
export AUDITFILE=/etc/audit/auditd.conf
touch $TESTFILE
touch $AUDITFILE
chmod 0600 $TESTFILE
chmod 0600 $AUDITFILE
