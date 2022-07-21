#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# remediation = none
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

authselect select sssd --force
authselect enable-feature with-faillock
# This test scenario simulates conflicting settings in pam and faillock.conf files.
# It means that authselect is not properly configured and may have a unexpected behaviour. The
# authselect integrity check will fail and the remediation will be aborted in order to preserve
# intentional changes. In this case, an informative message will be shown in the remediation report.
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 unlock_time=600/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "unlock_time=600" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
