#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_POSTLOGIN="/etc/authselect/$CUSTOM_PROFILE/postlogin"
sed -i --follow-symlinks '/session.*required.*pam_lastlog\.so/d' $CUSTOM_POSTLOGIN
sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     required                   pam_lastlog.so silent showfailed\n&/' $CUSTOM_POSTLOGIN
authselect apply-changes -b
