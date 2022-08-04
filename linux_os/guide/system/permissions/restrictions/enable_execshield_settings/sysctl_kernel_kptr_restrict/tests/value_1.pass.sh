#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/kernel.kptr_restrict/d" /etc/sysctl.conf
echo "kernel.kptr_restrict = 1" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w kernel.kptr_restrict="1"
