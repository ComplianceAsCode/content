#!/bin/bash
# packages = sudo

{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch /etc/sudoers
{{% endif %}}
if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers
fi
