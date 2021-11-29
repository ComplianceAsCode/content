#!/bin/bash
# remediation = none

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
else
    authselect enable-feature with-faillock
fi
# Ensure the parameters only in /etc/security/faillock.conf
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "even_deny_root" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
