#!/bin/bash
#

if grep -q "^gpgcheck" /etc/yum.conf; then
	sed -i "s/^gpgcheck.*/gpgcheck=0/" /etc/yum.conf
else
	echo "gpgcheck=0" >> /etc/yum.conf
fi
