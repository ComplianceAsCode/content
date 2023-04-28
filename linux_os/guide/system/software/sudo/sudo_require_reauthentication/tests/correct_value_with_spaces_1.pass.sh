#!/bin/bash
# packages = sudo

# Set Defaults timestamp_timeout in /etc/sudoers 
if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout = +2.5/' /etc/sudoers
else
	echo "Defaults timestamp_timeout = +2.5" >> /etc/sudoers
fi

# Remove Defaults timestamp_timeout from /etc/sudoers.d/00-complianceascode-test.conf
if grep -q 'timestamp_timeout' /etc/sudoers.d/00-complianceascode-test.conf; then
	sed -i '/.*timestamp_timeout.*/d' /etc/sudoers.d/00-complianceascode-test.conf
fi
