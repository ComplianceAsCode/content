#!/bin/bash

sed -i "/^net.ipv4.ip_local_port_range.*/d" /etc/sysctl.conf
# setting correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w net.ipv4.ip_local_port_range="32768 65535"
