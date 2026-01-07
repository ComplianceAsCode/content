#!/bin/bash
# platform = multi_platform_rhel
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
authselect enable-feature with-pwhistory
pam_profile_path="/etc/authselect/$CUSTOM_PROFILE"

for authselect_file in "$pam_profile_path"/password-auth "$pam_profile_path"/system-auth; do
    if grep -Pq '^\h*password\h+([^#\n\r]+)\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?use_authtok\b' "$authselect_file"; then
        sed -i 's/use_authtok//g' "$authselect_file"
    fi
done
authselect apply-changes
