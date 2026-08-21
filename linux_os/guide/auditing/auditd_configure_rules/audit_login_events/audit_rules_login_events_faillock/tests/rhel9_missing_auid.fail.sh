#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit
# variables = var_accounts_passwords_pam_faillock_dir=/var/log/faillock

# This test should fail because it's missing the auid filters
echo "-a always,exit -F arch=b32 -F path=/var/log/faillock -F perm=wa -F key=logins" >> /etc/audit/rules.d/logins.rules
echo "-a always,exit -F arch=b64 -F path=/var/log/faillock -F perm=wa -F key=logins" >> /etc/audit/rules.d/logins.rules
