#!/bin/bash
# packages = sudo

{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch /etc/sudoers
{{% endif %}}
# Remove Defaults timestamp_timeout from sudoers
if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers
fi

# Set Defaults timestamp_timeout in /etc/sudoers.d/00-complianceascode-test.conf
if grep -q 'timestamp_timeout' /etc/sudoers.d/00-complianceascode-test.conf; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=+0/' /etc/sudoers.d/00-complianceascode-test.conf
else
	echo "Defaults timestamp_timeout=+0" >> /etc/sudoers.d/00-complianceascode-test.conf
fi
