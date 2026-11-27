#!/bin/bash
# remediation = none
{{% if 'sle' in product or 'slmicro' in product %}}
# packages = libselinux1
{{% else %}}
# packages = python3-libselinux
{{% endif %}}

. $SHARED/group_updating_utils.sh

config_file="$(find_config_file)"

# gpgcheck is enabled, but a later line disables it with a mixed-case value and
# whitespace around the "=". dnf lowercases boolean values before parsing, so
# "Off" is read exactly like "off" and signature checking is off. A scan that
# matched the disable value case-sensitively would miss this and wrongly report
# the host as compliant.
if grep -q "^gpgcheck" "$config_file"; then
	sed -i "s/^gpgcheck.*/gpgcheck=1/" "$config_file"
else
	echo "gpgcheck=1" >> "$config_file"
fi
echo "gpgcheck = Off" >> "$config_file"
