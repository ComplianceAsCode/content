#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_rhv,multi_platform_sle
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect select sssd --force
    authselect disable-feature with-faillock
fi
