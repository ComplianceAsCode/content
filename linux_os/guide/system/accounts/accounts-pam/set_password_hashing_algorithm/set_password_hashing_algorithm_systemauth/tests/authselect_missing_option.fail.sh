#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force
CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
sed -i --follow-symlinks '/^password.*sufficient.*pam_unix.so/ s/sha512//g' $CUSTOM_SYSTEM_AUTH
authselect apply-changes -b
