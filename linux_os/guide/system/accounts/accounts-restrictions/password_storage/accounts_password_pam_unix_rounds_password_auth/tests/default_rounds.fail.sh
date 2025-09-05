#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora
# packages = pam
# variables = var_password_pam_unix_rounds=5000


pamFile="/etc/pam.d/password-auth"

# Make sure rounds is not set.
sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                s/rounds=[[:digit:]]\+//" $pamFile
