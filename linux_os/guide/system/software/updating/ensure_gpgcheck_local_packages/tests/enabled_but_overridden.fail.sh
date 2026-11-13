#!/bin/bash
# remediation = none
{{% if 'sle' in product or 'slmicro' in product %}}
# packages = libselinux1
{{% else %}}
# packages = python3-libselinux
{{% endif %}}

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

# An enabling line is present, but a later line in the same [main] section
# disables localpkg_gpgcheck. The package manager uses the last assignment,
# so local package signature checking is effectively off.
if grep -q "^localpkg_gpgcheck" "$config_file"; then
	sed -i "s/^localpkg_gpgcheck.*/localpkg_gpgcheck=1/" "$config_file"
else
	echo "localpkg_gpgcheck=1" >> "$config_file"
fi
echo "localpkg_gpgcheck=0" >> "$config_file"
