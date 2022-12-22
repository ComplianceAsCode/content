#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# variables = var_password_pam_remember=5,var_password_pam_remember_control_flag=requisite

if authselect list-features minimal | grep -q with-pwhistory; then
    authselect select sssd --force
    authselect disable-feature with-pwhistory
else
    authselect create-profile hardening -b sssd
    CUSTOM_PROFILE="custom/hardening"
    authselect select $CUSTOM_PROFILE --force
    CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
    sed -i --follow-symlinks '/.*pam_pwhistory\.so/d' $CUSTOM_PASSWORD_AUTH
fi
authselect apply-changes -b
> /etc/security/pwhistory.conf
