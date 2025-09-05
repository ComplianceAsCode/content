#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# variables = var_password_pam_retry=3

source common.sh

CONF_FILE="/etc/security/pwquality.conf"

retry_cnt=3
if grep -q "^.*retry\s*=" "$CONF_FILE"; then
	sed -i "s/^.*retry\s*=.*/# retry = $retry_cnt/" "$CONF_FILE"
else
	echo "# retry = $retry_cnt" >> "$CONF_FILE"
fi

for file in ${configuration_files[@]}; do
	echo "password required pam_pwquality.so" >> \
		"/etc/authselect/custom/testingProfile/$file"
done

authselect apply-changes
