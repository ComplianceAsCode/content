#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
if [ $(grep -c "^\s*password.*pam_pwquality\.so" $CUSTOM_SYSTEM_AUTH) -eq 0 ]; then
    sed -i --follow-symlinks '0,/^password.*/s/^password.*/password     requisite   pam_pwquality.so\n&/' $CUSTOM_SYSTEM_AUTH
else
    sed -r -i --follow-symlinks 's/(^password.*)(required|requisite)(.*pam_pwquality\.so.*)$/\1requisite\3/' $CUSTOM_SYSTEM_AUTH
fi
authselect apply-changes -b
