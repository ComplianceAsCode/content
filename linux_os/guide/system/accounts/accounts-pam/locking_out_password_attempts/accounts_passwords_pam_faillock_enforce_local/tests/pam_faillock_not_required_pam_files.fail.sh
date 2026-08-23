#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# remediation = none

# This test scenario manually modify the pam_faillock.so entries in auth section from
# "required" to "sufficient". This makes pam_faillock.so behave differently than initially
# intentioned. We catch this, but we can't safely remediate in an automated way.
authselect select sssd --force
authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "local_users_only" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
sed -i --follow-symlinks 's/\(^\s*auth\s*\)\(\s.*\)\(pam_faillock\.so.*$\)/\1 sufficient \3/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
