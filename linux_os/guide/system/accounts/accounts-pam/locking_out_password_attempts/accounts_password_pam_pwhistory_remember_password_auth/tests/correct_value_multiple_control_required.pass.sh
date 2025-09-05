#!/bin/bash
# packages = pam
# platform = Oracle Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
sed -i --follow-symlinks '/.*pam_pwhistory\.so/d' $CUSTOM_PASSWORD_AUTH
echo "password required pam_pwhistory.so use_authtok remember=5 retry=3" >> $CUSTOM_PASSWORD_AUTH
authselect apply-changes -b
