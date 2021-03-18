#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv4.conf.default.accept_source_route/d" /etc/sysctl.conf

sysctl -w net.ipv4.conf.default.accept_source_route=0
