#!/bin/bash

# Sets the kernel setting using sysctl exec as well as in sysctl config file.
# $1: The setting name without the leading 'kernel.'
# $2: The value to set the setting to
function sysctl_set_kernel_setting_to {
	local setting_name="kernel.$1" setting_value="$2"
	sysctl -w "$setting_name=$setting_value"
	if grep -q "^$setting_name" /etc/sysctl.conf; then
		sed -i "s/^$setting_name.*/$setting_name = $setting_value/" /etc/sysctl.conf
	else
		echo "$setting_name = $setting_value" >> /etc/sysctl.conf
	fi
}
