#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# remediation = none

authselect select sssd --force
authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "local_users_only" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
