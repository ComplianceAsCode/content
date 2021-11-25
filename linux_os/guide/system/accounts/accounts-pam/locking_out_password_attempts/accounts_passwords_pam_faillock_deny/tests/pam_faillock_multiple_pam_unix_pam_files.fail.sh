#!/bin/bash
# remediation = none
# variables = var_accounts_passwords_pam_faillock_deny=3

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="deny=3" --update
else
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 deny=3/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
if [ -f /etc/security/faillock.conf ]; then
    > /etc/security/faillock.conf
fi

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected bevaviour of pam_faillock.so.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
