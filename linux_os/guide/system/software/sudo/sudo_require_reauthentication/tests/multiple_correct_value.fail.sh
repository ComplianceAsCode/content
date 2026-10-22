#!/bin/bash
# packages = sudo
# variables = var_sudo_timestamp_timeout=3

if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=3/' /etc/sudoers
else
	echo "Defaults timestamp_timeout=3" >> /etc/sudoers
fi

echo "Defaults timestamp_timeout = 3" > /etc/sudoers.d/00-complianceascode-test.conf
