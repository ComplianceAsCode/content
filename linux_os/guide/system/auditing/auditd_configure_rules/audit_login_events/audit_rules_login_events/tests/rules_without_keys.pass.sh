#!/bin/bash
# packages = audit
# remediation = bash
# variables = var_accounts_passwords_pam_faillock_dir=/var/log/faillock

echo "-w /var/log/faillock -p wa" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/lastlog -p wa" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/tallylog -p wa" >> /etc/audit/rules.d/logins.rules
