#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_rhv,multi_platform_sle
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
# remediation = none
{{%- endif %}}
# variables = var_accounts_passwords_pam_faillock_deny=3

# This test scenario manually modify the pam_faillock.so entries in auth section from
# "required" to "sufficient". This makes pam_faillock.so behave differently than initially
# intentioned. We catch this, but we can't safely remediate in an automated way.
if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="deny=3" --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 deny=3/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
sed -i --follow-symlinks 's/\(^\s*auth\s*\)\(\s.*\)\(pam_faillock\.so.*$\)/\1 sufficient \3/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
if [ -f /etc/security/faillock.conf ]; then
    > /etc/security/faillock.conf
fi
