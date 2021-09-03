#!/bin/bash

# make existing entries pass
# assumption: use a nominally small value for var_accounts_maximum_age_login_defs
#             so as to not interfere.
for acct in $(grep -ve ':\(!!\|\*\):' /etc/shadow | awk -F: '{print $1}'); do
    chage -M 1 -d $(date +%Y-%m-%d) $acct
done
# Add  test entries
# Noninteractive users are a pass
echo "max-test-user:x:540:540:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "max-test-user:!!:18648:1::::" >> /etc/shadow

