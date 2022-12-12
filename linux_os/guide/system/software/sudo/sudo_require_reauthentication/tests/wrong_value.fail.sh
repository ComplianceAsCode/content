#!/bin/bash
# packages = sudo

if grep -q 'timestamp_timeout' /etc/sudoers; then
	sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=-1/' /etc/sudoers
else
	echo "Defaults timestamp_timeout=-1" >> /etc/sudoers
fi
