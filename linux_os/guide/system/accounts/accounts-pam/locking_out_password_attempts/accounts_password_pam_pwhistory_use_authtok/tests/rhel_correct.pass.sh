#!/bin/bash
# platform = multi_platform_rhel

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
authselect enable-feature with-pwhistory
pam_profile_path="/etc/authselect/$CUSTOM_PROFILE"

for authselect_file in "$pam_profile_path"/password-auth "$pam_profile_path"/system-auth; do
    sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwhistory\.so\s+.*)$/& use_authtok/g' "$authselect_file"
done
authselect apply-changes
