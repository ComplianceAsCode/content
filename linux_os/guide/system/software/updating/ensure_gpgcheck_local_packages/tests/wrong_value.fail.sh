#!/bin/bash
# packages = python3-libselinux

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

if grep -q "^localpkg_gpgcheck" "$config_file" ; then
	sed -i "s/^localpkg_gpgcheck.*/localpkg_gpgcheck=0/" "$config_file"
else
	echo "localpkg_gpgcheck=0" >> "$config_file"
fi
