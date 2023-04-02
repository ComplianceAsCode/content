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

# Clean sysctl config directories, but also ensure barest configuration infra
# exists
function sysctl_reset {
	mkdir -p /lib/sysctl.d /usr/lib/sysctl.d /usr/local/lib/sysctl.d /run/sysctl.d /etc/sysctl.d
	rm -rf /lib/sysctl.d/* /usr/lib/sysctl.d/* /usr/local/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*
	touch /etc/sysctl.conf
}
