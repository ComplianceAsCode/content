#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7,multi_platform_fedora
# remediation = none

{{{ tests_init_faillock_vars("correct") }}}

authconfig --enablefaillock --faillockargs="$PRM_NAME=$TEST_VALUE" --update

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so. Remediation does not solve this automatically
# in order to preserve intentional changes.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
