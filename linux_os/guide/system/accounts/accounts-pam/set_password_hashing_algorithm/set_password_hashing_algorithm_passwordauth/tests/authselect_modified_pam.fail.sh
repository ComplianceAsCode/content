#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora
# variables = var_password_hashing_algorithm_pam=sha512
# remediation = none

PASSWORD_AUTH_FILE="/etc/pam.d/password-auth"

# This modification will break the integrity checks done by authselect.
sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/sha512//g' $PASSWORD_AUTH_FILE
sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/yescrypt//g' $PASSWORD_AUTH_FILE
echo "session     optional    pam_unix.so" >> $PASSWORD_AUTH_FILE
