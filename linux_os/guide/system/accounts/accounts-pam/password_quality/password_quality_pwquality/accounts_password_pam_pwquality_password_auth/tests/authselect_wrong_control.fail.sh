#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_PASSWORD_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
if [ $(grep -c "^\s*password.*requisite.*pam_pwquality.so" $CUSTOM_PASSWORD_AUTH) -eq 0 ]; then
    sed -i --follow-symlinks "/^account.*required.*pam_permit.so/a password    optional     pam_pwquality.so" $CUSTOM_PASSWORD_AUTH
else
    sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwquality\.so.*)$/\1optional\3/" $CUSTOM_PASSWORD_AUTH
fi
authselect apply-changes -b
