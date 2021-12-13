#!/bin/bash
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}
# remediation = none
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
fi
# Ensure the parameters only in /etc/security/faillock.conf
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "unlock_time=600" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected bevaviour of pam_faillock.so.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
