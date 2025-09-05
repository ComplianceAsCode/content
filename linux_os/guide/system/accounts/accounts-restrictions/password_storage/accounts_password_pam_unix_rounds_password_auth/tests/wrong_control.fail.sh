#!/bin/bash
# packages = pam
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol
# variables = var_password_pam_unix_rounds=65536

ROUNDS=65536
pam_file="/etc/pam.d/password-auth"

if ! $(grep -q "^\s*password.*pam_unix.so.*rounds=" $pam_file); then
	sed -i --follow-symlinks "/^\s*password.*pam_unix.so/ s/$/ rounds=$ROUNDS/" $pam_file
fi
sed -i --follow-symlinks -E 's/^(password.*)sufficient(.*pam_unix.so.*)/\1optional\2/' $pam_file
