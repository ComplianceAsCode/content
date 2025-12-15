#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux
# packages = pam

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"

# Ensure system-auth and password-auth don't have remember option
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' $CUSTOM_SYSTEM_AUTH
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' $CUSTOM_PASSWORD_AUTH

# Add a clean pam_unix.so line without remember if it doesn't exist
if ! grep -q "^password.*pam_unix\.so" $CUSTOM_SYSTEM_AUTH; then
    echo "password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok" >> $CUSTOM_SYSTEM_AUTH
fi

if ! grep -q "^password.*pam_unix\.so" $CUSTOM_PASSWORD_AUTH; then
    echo "password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok" >> $CUSTOM_PASSWORD_AUTH
fi

authselect apply-changes -b
