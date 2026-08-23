#!/bin/bash
# platform = multi_platform_rhel,multi_platform_sle
# variables = var_password_pam_retry=3
{{% if product in ['sle15', 'sle16'] %}}
# packages = libpwquality1
{{% else %}}
# packages = authselect
{{% endif %}}

source common.sh

CONF_FILE="{{{ pwquality_path }}}"

retry_cnt=3
if grep -q "^.*retry\s*=" "$CONF_FILE"; then
	sed -i "s/^.*retry\s*=.*/retry = $retry_cnt/" "$CONF_FILE"
else
	echo "retry = $retry_cnt" >> "$CONF_FILE"
fi
{{% if product not in ['sle15', 'sle16'] %}}
for file in ${configuration_files[@]}; do
	echo "password required pam_pwquality.so" >> \
		"/etc/authselect/custom/testingProfile/$file"
done

authselect apply-changes
{{% endif %}}
