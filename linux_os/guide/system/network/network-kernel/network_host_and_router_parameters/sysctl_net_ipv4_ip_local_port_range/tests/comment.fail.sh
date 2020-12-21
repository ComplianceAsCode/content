#!/bin/bash

if grep -q "^net.ipv4.ip_local_port_range" /etc/sysctl.conf; then
	sed -i "s/^net.ipv4.ip_local_port_range.*/# net.ipv4.ip_local_port_range = 32768 65535/" /etc/sysctl.conf
else
	echo "# net.ipv4.ip_local_port_range = 32768 65535" >> /etc/sysctl.conf
fi
# setting correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w net.ipv4.ip_local_port_range="32768 65535"
