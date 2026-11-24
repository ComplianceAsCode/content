#!/bin/bash
# platform = multi_platform_rhel
# packages = authselect
authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
sed -i -E '/^\s*password\s+.*pam_unix\.so/ s/\s+use_authtok\b//' \
    "/etc/authselect/$CUSTOM_PROFILE/system-auth" "/etc/authselect/$CUSTOM_PROFILE/password-auth"
authselect apply-changes
