#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none
# variables = var_password_pam_unix_rounds=65536

ROUNDS=5000
PASSWORD_AUTH_FILE="/etc/pam.d/password-auth"
# This modification will break the integrity checks done by authselect.
if ! $(grep -q "^\s*password.*pam_unix\.so.*rounds=" $PASSWORD_AUTH_FILE); then
	sed -i --follow-symlinks "/^\s*password.*pam_unix\.so/ s/$/ rounds=$ROUNDS/" $PASSWORD_AUTH_FILE
else
	sed -r -i --follow-symlinks "s/(^\s*password.*pam_unix\.so.*)(rounds=[[:digit:]]+)(.*)/\1rounds=$ROUNDS \3/g" $PASSWORD_AUTH_FILE
fi
