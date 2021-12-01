#!/bin/bash
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="unlock_time=600" --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 unlock_time=600/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
if [ -f /etc/security/faillock.conf ]; then
    > /etc/security/faillock.conf
fi
