#!/bin/bash
# packages = sudo

{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch /etc/sudoers
{{% endif %}}
# Remove Defaults timestamp_timeout from /etc/sudoers
if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers
fi

# Remove Defaults timestamp_timeout from /etc/sudoers.d/00-complianceascode-test.conf
if grep -q 'timestamp_timeout' /etc/sudoers.d/00-complianceascode-test.conf; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers.d/00-complianceascode-test.conf
fi
