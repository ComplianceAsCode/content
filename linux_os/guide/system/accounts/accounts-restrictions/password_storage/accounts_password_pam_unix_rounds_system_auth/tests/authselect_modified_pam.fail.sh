#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none
# variables = var_password_pam_unix_rounds=65536

ROUNDS=5000
SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"
# This modification will break the integrity checks done by authselect.
if ! $(grep -q "^\s*password.*pam_unix\.so.*rounds=" $SYSTEM_AUTH_FILE); then
	sed -i --follow-symlinks "/^\s*password.*pam_unix\.so/ s/$/ rounds=$ROUNDS/" $SYSTEM_AUTH_FILE
else
	sed -r -i --follow-symlinks "s/(^\s*password.*pam_unix\.so.*)(rounds=[[:digit:]]+)(.*)/\1rounds=$ROUNDS \3/g" $SYSTEM_AUTH_FILE
fi
