#!/bin/bash
# platform = Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_almalinux

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv4.conf.all.rp_filter/d" /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 2" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w net.ipv4.conf.all.rp_filter="2"
