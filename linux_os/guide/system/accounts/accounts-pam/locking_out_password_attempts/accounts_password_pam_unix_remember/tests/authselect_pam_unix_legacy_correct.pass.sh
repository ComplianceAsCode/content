#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# variables = var_password_pam_unix_remember=5

remember_cnt=5
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
sed -i --follow-symlinks '/.*pam_pwhistory\.so/d' $CUSTOM_SYSTEM_AUTH

if ! $(grep -q "^[^#].*pam_unix\.so.*remember=" $CUSTOM_SYSTEM_AUTH); then
    sed -i --follow-symlinks "/pam_unix.so/ s/$/ remember=$remember_cnt/" $CUSTOM_SYSTEM_AUTH
else
    sed -i --follow-symlinks "s/^(.*pam_unix\.so.*)(remember=[0-9]+)(.*)$/\1remember=$remember_cnt\3/" $CUSTOM_SYSTEM_AUTH
fi
authselect apply-changes -b

> /etc/security/pwhistory.conf
