#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux
# packages = pam

# Add remember option to password-auth (should fail)
if grep -q "^password.*pam_unix\.so" /etc/pam.d/password-auth; then
    # If pam_unix.so line exists, add remember option
    sed -i --follow-symlinks 's/\(^password.*pam_unix\.so.*\)/\1 remember=5/' /etc/pam.d/password-auth
else
    # If no pam_unix.so line exists, add one with remember
    echo "password    sufficient    pam_unix.so sha512 shadow remember=5" >> /etc/pam.d/password-auth
fi
