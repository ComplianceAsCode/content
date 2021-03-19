#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/fs.suid_dumpable/d" /etc/sysctl.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
# Setting wrong runtime value
sysctl -w fs.suid_dumpable=1
