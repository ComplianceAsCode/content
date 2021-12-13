#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# variables = var_accounts_passwords_pam_faillock_deny=3

authselect select sssd --force
authselect enable-feature with-faillock
# Ensure the parameters only in /etc/security/faillock.conf if the file is present.
# NOTE:
# Older versions of authselect, which don't support faillock.conf will complain if any change
# are made in pam files, even for different but valid arguments. In practical, if any change in
# default pam_faillock.so parameters is necessary for hardening, old versions of authselect no
# longer can be used to manage pam. This will impact the ansible remediation for older versions
# of authselect in the specific context of this test scenario, for example, in a RHEL 8.0 and 8.1.
if [ -f /etc/security/faillock.conf ]; then
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
> /etc/security/faillock.conf
echo "deny = 5" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
