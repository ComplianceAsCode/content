#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = python3-libselinux

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

if grep -q "^gpgcheck" "$config_file"; then
    sed -i "s/^gpgcheck.*/gpgcheck=TRUE/" "$config_file"
else
    echo "gpgcheck=TRUE" >> "$config_file"
fi
