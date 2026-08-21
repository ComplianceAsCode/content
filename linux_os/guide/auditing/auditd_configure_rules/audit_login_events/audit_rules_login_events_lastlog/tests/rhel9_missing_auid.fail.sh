#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

# This test should fail because it's missing the auid filters
echo "-a always,exit -F arch=b32 -F path=/var/log/lastlog -F perm=wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-a always,exit -F arch=b64 -F path=/var/log/lastlog -F perm=wa -k logins" >> /etc/audit/rules.d/logins.rules
