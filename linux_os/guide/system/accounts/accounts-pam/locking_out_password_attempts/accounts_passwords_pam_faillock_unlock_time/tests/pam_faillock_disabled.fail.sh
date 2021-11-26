#!/bin/bash
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect disable-feature with-faillock
fi
