#!/bin/bash

function find_config_file {
	if which dnf >/dev/null ; then
		config_file="/etc/dnf/dnf.conf"
	else
		config_file="/etc/yum.conf"
	fi
	echo $config_file
}
