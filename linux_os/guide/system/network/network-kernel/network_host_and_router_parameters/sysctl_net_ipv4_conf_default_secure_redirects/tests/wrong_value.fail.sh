#!/bin/bash

if grep -q "^net.ipv4.conf.default.secure_redirects" /etc/sysctl.conf; then
	sed -i "s/^net.ipv4.conf.default.secure_redirects.*/net.ipv4.conf.default.secure_redirects = 1/" /etc/sysctl.conf
else
	echo "net.ipv4.conf.default.secure_redirects = 1" >> /etc/sysctl.conf
fi

sysctl -w net.ipv4.conf.default.secure_redirects=1
