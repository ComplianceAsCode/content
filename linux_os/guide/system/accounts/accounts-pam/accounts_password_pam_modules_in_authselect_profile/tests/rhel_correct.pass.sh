#!/bin/bash
# platform = multi_platform_rhel

# Create a custom authselect profile
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

# Enable required features
authselect enable-feature with-pwhistory
authselect enable-feature with-faillock

pam_profile_path="/etc/authselect/$CUSTOM_PROFILE"

authselect apply-changes
