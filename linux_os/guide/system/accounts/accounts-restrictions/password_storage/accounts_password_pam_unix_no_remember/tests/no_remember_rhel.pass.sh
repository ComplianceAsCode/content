#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux
# packages = pam

# Ensure system-auth and password-auth don't have remember option
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' /etc/pam.d/system-auth
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' /etc/pam.d/password-auth

# Add a clean pam_unix.so line without remember if it doesn't exist
if ! grep -q "^password.*pam_unix\.so" /etc/pam.d/system-auth; then
    echo "password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok" >> /etc/pam.d/system-auth
fi

if ! grep -q "^password.*pam_unix\.so" /etc/pam.d/password-auth; then
    echo "password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok" >> /etc/pam.d/password-auth
fi
