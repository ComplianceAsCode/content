#!/bin/bash
# packages = sudo

# Set Defaults timestamp_timeout in /etc/sudoers 
if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=-1/' /etc/sudoers
else
	echo "Defaults timestamp_timeout=-1" >> /etc/sudoers
fi

# Set Defaults timestamp_timeout in /etc/sudoers.d/00-complianceascode-test.conf
if grep -q 'timestamp_timeout' /etc/sudoers.d/00-complianceascode-test.conf; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=0/' /etc/sudoers.d/00-complianceascode-test.conf
else
	echo "Defaults timestamp_timeout=0" >> /etc/sudoers.d/00-complianceascode-test.conf
fi
