#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# variables = var_password_hashing_algorithm_pam=sha512

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"

declare -a HASHING_ALGORITHMS_OPTIONS=("sha512" "yescrypt")
for hash_option in "${HASHING_ALGORITHMS_OPTIONS[@]}"; do
    if ! $(grep -q "^password.*sufficient.*pam_unix\.so.*$hash_option" "$CUSTOM_PASSWORD_AUTH"); then
        sed -i --follow-symlinks "/^password.*sufficient.*pam_unix\.so/ s/$/ $hash_option/" "$CUSTOM_PASSWORD_AUTH"
    fi
done
authselect apply-changes -b
