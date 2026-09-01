#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

# This test should fail because it's missing the b32 arch rule
echo "-a always,exit -F arch=b64 -F path=/var/log/lastlog -F perm=wa -F auid>=1000 -F auid!=unset -k logins" >> /etc/audit/rules.d/logins.rules
