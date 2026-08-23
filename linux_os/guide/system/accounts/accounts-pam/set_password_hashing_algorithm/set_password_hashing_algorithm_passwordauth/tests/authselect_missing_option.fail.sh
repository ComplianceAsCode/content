#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora
# variables = var_password_hashing_algorithm_pam=sha512

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"

declare -a HASHING_ALGORITHMS_OPTIONS=("sha512" "yescrypt" "gost_yescrypt" "blowfish" "sha256" "md5" "bigcrypt")

for hash_option in "${HASHING_ALGORITHMS_OPTIONS[@]}"; do
    if grep -qP "^\s*password\s+.*\s+pam_unix.so\s+.*\b$hash_option\b" "$CUSTOM_PASSWORD_AUTH"; then
        sed -i -E --follow-symlinks "s/(.*password\s+.*\s+pam_unix.so.*)$hash_option\s*(.*)/\1\2/g" "$CUSTOM_PASSWORD_AUTH"
    fi
done
authselect apply-changes -b
