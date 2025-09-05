#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv4.conf.default.rp_filter/d" /etc/sysctl.conf

sysctl -w net.ipv4.conf.default.rp_filter=1
