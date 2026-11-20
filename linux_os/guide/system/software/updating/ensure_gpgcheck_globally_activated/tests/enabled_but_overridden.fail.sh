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
# disables gpgcheck. The package manager uses the last assignment, so
# signature checking is effectively off even though "gpgcheck=1" is present.
if grep -q "^gpgcheck" "$config_file"; then
	sed -i "s/^gpgcheck.*/gpgcheck=1/" "$config_file"
else
	echo "gpgcheck=1" >> "$config_file"
fi
echo "gpgcheck=0" >> "$config_file"
