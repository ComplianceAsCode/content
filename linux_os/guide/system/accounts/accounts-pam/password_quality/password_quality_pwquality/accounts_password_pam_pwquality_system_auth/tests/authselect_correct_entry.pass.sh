#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
{{% if product == "rhel8" or product == "rhel9" %}}
{{% set pam_pwquality_control = "required" %}}
{{% else %}}
{{% set pam_pwquality_control = "requisite" %}}
{{% endif %}}
if [ $(grep -c "^\s*password.*{{{ pam_pwquality_control }}}.*pam_pwquality\.so" $CUSTOM_SYSTEM_AUTH) -eq 0 ]; then
    sed -i --follow-symlinks '0,/^password.*/s/^password.*/password     {{{ pam_pwquality_control }}}   pam_pwquality.so\n&/' $CUSTOM_SYSTEM_AUTH
fi
authselect apply-changes -b
