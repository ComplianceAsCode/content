#!/bin/bash
{{% if 'sle' in product %}}
# packages = libselinux
{{% else %}} 
# packages = python3-libselinux
{{% endif %}}

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

sed -i "/^gpgcheck.*/d" "$config_file"
