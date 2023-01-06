#!/bin/bash
# variables = var_accounts_minimum_age_login_defs=1,var_accounts_maximum_age_login_defs=60

# make existing entries pass
for acct in $(awk -F: '(/^[^:]+:[^!*]/ && ($4 < 1 || $4 == "")) {print $1}' /etc/shadow ); do
    chage -m 1 -d $(date +%Y-%m-%d) $acct
done
# Noninteractive users are a pass
echo "max-test-user:x:540:540:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "max-test-user:!!:18648:1::::" >> /etc/shadow

