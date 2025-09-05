#!/bin/bash
# packages = python3-libselinux

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

if grep -q "^gpgcheck" "$config_file"; then
	sed -i "s/^gpgcheck.*/gpgcheck=1/" "$config_file"
else
	echo "gpgcheck=1" >> "$config_file"
fi
