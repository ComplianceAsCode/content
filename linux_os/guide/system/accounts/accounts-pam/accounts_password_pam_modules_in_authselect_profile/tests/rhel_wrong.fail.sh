#!/bin/bash
# platform = multi_platform_rhel

# Create a custom authselect profile
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

pam_profile_path="/etc/authselect/$CUSTOM_PROFILE"
sed -i '/pam_faillock\.so/d' "$pam_profile_path"/password-auth
sed -i '/pam_faillock\.so/d' "$pam_profile_path"/system-auth
authselect apply-changes
