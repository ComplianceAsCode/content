#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv4.conf.default.accept_source_route/d" /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf

# Put a config file out of the default dirs
echo "net.ipv4.conf.default.accept_source_route = 0" >> /root/root-sysctl.conf

# Add a symlink
ln -s /root/root-sysctl.conf /etc/sysctl.d/90-root.conf

sysctl -w net.ipv4.conf.default.accept_source_route=0
