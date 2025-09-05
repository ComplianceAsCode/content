#!/bin/bash
# platform = multi_platform_ubuntu
# remediation = none

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so. Remediation does not solve this automatically
# in order to preserve intentional changes.

source ubuntu_common.sh

echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/common-auth
