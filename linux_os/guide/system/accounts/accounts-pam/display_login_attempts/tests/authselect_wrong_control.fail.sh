#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_POSTLOGIN="/etc/authselect/$CUSTOM_PROFILE/postlogin"
if ! $(grep -q "^[^#].*pam_lastlog\.so.*showfailed" $CUSTOM_POSTLOGIN); then
    sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     optional                   pam_lastlog.so showfailed\n&/' $CUSTOM_POSTLOGIN
else
    sed -r -i --follow-symlinks "s/(^session.*)(required|requisite)(.*pam_lastlog\.so.*)$/\1optional\3/" $CUSTOM_POSTLOGIN
fi
authselect apply-changes -b
