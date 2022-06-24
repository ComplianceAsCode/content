#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_POSTLOGIN="/etc/authselect/$CUSTOM_PROFILE/postlogin"
if [ $(grep -c "^\s*session.*required.*pam_lastlog.so\s\+showfailed\s*$" $CUSTOM_POSTLOGIN) -eq 0 ]; then
    sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     required                   pam_lastlog.so showfailed\n&/' $CUSTOM_POSTLOGIN
fi
echo "session     optional pam_lastlog.so silent showfailed" >> $CUSTOM_POSTLOGIN
authselect apply-changes -b
