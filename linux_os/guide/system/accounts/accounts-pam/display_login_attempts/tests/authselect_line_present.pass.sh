#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_POSTLOGIN="/etc/authselect/$CUSTOM_PROFILE/postlogin"
if [ $(grep -c "^\s*session.*required.*pam_lastlog\.so\s\+showfailed\s*$" $CUSTOM_POSTLOGIN) -eq 0 ]; then
    sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     required                   pam_lastlog.so showfailed\n&/' $CUSTOM_POSTLOGIN
fi
if [ $(grep -c "^\s*session.*pam_lastlog\.so.*silent$" $CUSTOM_POSTLOGIN) -eq 0 ]; then
    sed -i --follow-symlinks 's/^\(session.*pam_lastlog\.so.*\) silent\( .*\)/\1\2/g' $CUSTOM_POSTLOGIN
fi
authselect apply-changes -b
