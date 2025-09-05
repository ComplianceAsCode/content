#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv4.ip_forward/d" /etc/sysctl.conf
echo "# net.ipv4.ip_forward = 0" >> /etc/sysctl.conf

sysctl -w net.ipv4.ip_forward=0
