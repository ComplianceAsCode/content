#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# remediation = none

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_POSTLOGIN="/etc/authselect/$CUSTOM_PROFILE/postlogin"
sed -i --follow-symlinks '/session\s*\[default=1\]\s*pam_lastlog\.so.*showfailed.*/d' $CUSTOM_POSTLOGIN
authselect apply-changes -b

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"
# This modification will break the integrity checks done by authselect.
if ! grep -q "^[^#].*pam_pwhistory\.so.*remember=" $SYSTEM_AUTH_FILE; then
	sed -i --follow-symlinks "/^password.*requisite.*pam_pwquality\.so/a password    requisite     pam_pwhistory.so" $SYSTEM_AUTH_FILE
else
   sed -i --follow-symlinks "s/\(.*pam_pwhistory\.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1/g" $SYSTEM_AUTH_FILE
fi
