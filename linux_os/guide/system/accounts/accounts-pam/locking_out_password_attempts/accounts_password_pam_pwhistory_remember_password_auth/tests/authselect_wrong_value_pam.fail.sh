#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# variables = var_password_pam_remember=5,var_password_pam_remember_control_flag=requisite

remember_cnt=3
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
if ! $(grep -q "^[^#].*pam_pwhistory\.so.*remember=" $CUSTOM_PASSWORD_AUTH); then
    sed -i --follow-symlinks "/^password.*requisite.*pam_pwquality\.so/a password    requisite     pam_pwhistory.so remember=$remember_cnt use_authtok" $CUSTOM_PASSWORD_AUTH
else
    sed -i --follow-symlinks "s/\(.*pam_pwhistory\.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1$remember_cnt \2/g" $CUSTOM_PASSWORD_AUTH
fi
authselect apply-changes -b

> /etc/security/pwhistory.conf
