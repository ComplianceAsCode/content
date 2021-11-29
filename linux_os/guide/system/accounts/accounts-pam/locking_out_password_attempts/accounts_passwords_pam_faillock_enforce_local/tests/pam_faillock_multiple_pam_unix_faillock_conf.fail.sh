#!/bin/bash
# remediation = none

authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "local_users_only" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
