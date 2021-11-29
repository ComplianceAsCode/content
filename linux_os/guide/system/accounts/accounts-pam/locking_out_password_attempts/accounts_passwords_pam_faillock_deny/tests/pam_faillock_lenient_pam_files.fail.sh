#!/bin/bash
# variables = var_accounts_passwords_pam_faillock_deny=3

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="deny=5" --update
else
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 deny=5/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
if [ -f /etc/security/faillock.conf ]; then
    > /etc/security/faillock.conf
fi
