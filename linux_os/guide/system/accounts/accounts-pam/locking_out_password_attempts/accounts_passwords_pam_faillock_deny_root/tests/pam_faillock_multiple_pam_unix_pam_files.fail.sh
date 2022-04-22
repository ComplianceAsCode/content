#!/bin/bash
# packages = authconfig
# platform = multi_platform_fedora,Red Hat Enterprise Linux 7
# remediation = none

authconfig --enablefaillock --faillockargs="even_deny_root" --update

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so. Remediation does not solve this automatically
# in order to preserve intentional changes.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
