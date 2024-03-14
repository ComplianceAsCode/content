#!/bin/bash

{{% if 'sle' in product %}}
function find_config_file {
	config_file="/etc/zypp/zypp.conf"
	echo $config_file
}	
{{% else %}}
function find_config_file {
	if [ -f "/etc/dnf/dnf.conf" ]; then
		config_file="/etc/dnf/dnf.conf"
	else
		config_file="/etc/yum.conf"
	fi
	echo $config_file
}
{{% endif %}}