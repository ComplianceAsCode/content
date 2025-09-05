#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# variables = var_password_pam_remember=5,var_password_pam_remember_control_flag=requisite

remember_cnt=5
control=required
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
if ! $(grep -q "^[^#].*pam_pwhistory\.so.*remember=" $CUSTOM_SYSTEM_AUTH); then
    sed -i --follow-symlinks "/^password.*required.*pam_pwquality\.so/a password    $control     pam_pwhistory.so remember=$remember_cnt use_authtok" $CUSTOM_SYSTEM_AUTH
else
    sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1$control\3/" $CUSTOM_SYSTEM_AUTH
fi
authselect apply-changes -b
