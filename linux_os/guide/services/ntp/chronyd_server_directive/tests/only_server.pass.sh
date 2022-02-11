#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_rhel

sed -i "^pool.*" /etc/chrony.conf
echo "server 0.pool.ntp.org" > /etc/chrony.conf
