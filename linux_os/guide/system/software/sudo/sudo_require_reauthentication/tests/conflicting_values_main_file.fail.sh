#!/bin/bash
# packages = sudo
# variables = var_sudo_timestamp_timeout=0

if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=-1/' /etc/sudoers
else
	echo "Defaults timestamp_timeout=-1" >> /etc/sudoers 
fi
echo "Defaults timestamp_timeout=0" >> /etc/sudoers 
