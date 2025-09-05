#!/bin/bash

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/net.ipv4.icmp_ignore_bogus_error_responses/d" /etc/sysctl.conf

sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
