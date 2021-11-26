#!/bin/bash
# variables = var_accounts_passwords_pam_faillock_fail_interval=900

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
else
    authselect enable-feature with-faillock
fi
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 fail_interval=900/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "fail_interval=900" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
