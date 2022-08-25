#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/kernel.core_pattern/d" /etc/sysctl.conf
echo "kernel.core_pattern=|/bin/false" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w kernel.core_pattern="|/bin/false"
