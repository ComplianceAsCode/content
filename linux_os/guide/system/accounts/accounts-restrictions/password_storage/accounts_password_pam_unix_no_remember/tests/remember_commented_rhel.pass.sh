#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux
# packages = pam

# Commented lines should pass (comments are ignored)
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' /etc/pam.d/system-auth
sed -i --follow-symlinks '/pam_unix\.so.*remember=/d' /etc/pam.d/password-auth

# Add commented line with remember (should be ignored)
echo "# password    sufficient    pam_unix.so sha512 shadow remember=5" >> /etc/pam.d/system-auth
echo "# password    sufficient    pam_unix.so sha512 shadow remember=5" >> /etc/pam.d/password-auth

# Add clean active lines without remember
echo "password    sufficient    pam_unix.so sha512 shadow" >> /etc/pam.d/system-auth
echo "password    sufficient    pam_unix.so sha512 shadow" >> /etc/pam.d/password-auth
