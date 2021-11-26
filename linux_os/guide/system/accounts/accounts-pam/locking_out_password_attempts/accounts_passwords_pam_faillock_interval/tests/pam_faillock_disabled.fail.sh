#!/bin/bash
# variables = var_accounts_passwords_pam_faillock_fail_interval=900

if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect disable-feature with-faillock
fi
