#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux
# packages = pam

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"

# Commented lines should pass (comments are ignored)
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' $CUSTOM_SYSTEM_AUTH
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' $CUSTOM_PASSWORD_AUTH

# Add commented line with remember (should be ignored)
echo "# password    sufficient    pam_unix.so sha512 shadow remember=5" >> $CUSTOM_SYSTEM_AUTH
echo "# password    sufficient    pam_unix.so sha512 shadow remember=5" >> $CUSTOM_PASSWORD_AUTH

# Add clean active lines without remember
echo "password    sufficient    pam_unix.so sha512 shadow" >> $CUSTOM_SYSTEM_AUTH
echo "password    sufficient    pam_unix.so sha512 shadow" >> $CUSTOM_PASSWORD_AUTH

authselect apply-changes -b
