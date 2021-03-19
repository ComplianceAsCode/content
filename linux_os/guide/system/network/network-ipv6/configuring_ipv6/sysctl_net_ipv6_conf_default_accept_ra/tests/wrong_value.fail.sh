#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv6.conf.default.accept_ra/d" /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_ra = 1" >> /etc/sysctl.conf
# Setting correct runtime value
sysctl -w net.ipv6.conf.default.accept_ra=0
