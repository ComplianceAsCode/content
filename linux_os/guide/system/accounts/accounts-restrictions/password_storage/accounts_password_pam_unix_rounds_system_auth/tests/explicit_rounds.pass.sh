#!/bin/bash
# packages = pam
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol
# variables = var_password_pam_unix_rounds=65536

ROUNDS=65536
pamFile="/etc/pam.d/system-auth"

# Make sure rounds is set to default value
if grep -q "rounds=" $pamFile; then
    sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                    s/rounds=[[:digit:]]\+/rounds=$ROUNDS/" $pamFile
else
    sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ s/$/ rounds=$ROUNDS/" $pamFile
fi
