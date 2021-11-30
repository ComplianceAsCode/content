#!/bin/bash
#

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

sed -i "/^gpgcheck.*/d" "$config_file"
