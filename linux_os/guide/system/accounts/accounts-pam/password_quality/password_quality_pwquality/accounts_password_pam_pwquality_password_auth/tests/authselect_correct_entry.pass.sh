#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/password-auth"
if [ $(grep -c "^\s*password.*requisite.*pam_pwquality\.so" $CUSTOM_SYSTEM_AUTH) -eq 0 ]; then
    sed -i --follow-symlinks '0,/^password.*/s/^password.*/password     requisite   pam_pwquality.so\n&/' $CUSTOM_SYSTEM_AUTH
fi
authselect apply-changes -b
