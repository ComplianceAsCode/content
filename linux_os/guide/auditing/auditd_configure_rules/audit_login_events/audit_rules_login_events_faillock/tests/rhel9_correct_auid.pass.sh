#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit
# variables = var_accounts_passwords_pam_faillock_dir=/var/log/faillock

echo "-a always,exit -F arch=b32 -F path=/var/log/faillock -F perm=wa -F auid>=1000 -F auid!=unset -F key=logins" >> /etc/audit/rules.d/logins.rules
echo "-a always,exit -F arch=b64 -F path=/var/log/faillock -F perm=wa -F auid>=1000 -F auid!=unset -F key=logins" >> /etc/audit/rules.d/logins.rules
