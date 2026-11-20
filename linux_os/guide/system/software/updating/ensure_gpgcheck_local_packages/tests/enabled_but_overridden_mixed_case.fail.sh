#!/bin/bash
# remediation = none
{{% if 'sle' in product or 'slmicro' in product %}}
# packages = libselinux1
{{% else %}}
# packages = python3-libselinux
{{% endif %}}

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

# localpkg_gpgcheck is enabled, but a later line disables it with a mixed-case
# value and whitespace around the "=". dnf lowercases boolean values before
# parsing, so "No" is read exactly like "no" and local-package signature
# checking is off. A case-sensitive scan would miss this.
if grep -q "^localpkg_gpgcheck" "$config_file"; then
	sed -i "s/^localpkg_gpgcheck.*/localpkg_gpgcheck=1/" "$config_file"
else
	echo "localpkg_gpgcheck=1" >> "$config_file"
fi
echo "localpkg_gpgcheck = No" >> "$config_file"
