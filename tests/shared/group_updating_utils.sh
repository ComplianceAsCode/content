#!/bin/bash

function find_config_file {
	if [ -f "/etc/dnf/dnf.conf" ]; then
		config_file="/etc/dnf/dnf.conf"
	else
		config_file="/etc/yum.conf"
	fi
	echo $config_file
}
