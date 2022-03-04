#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel

{{{ bash_sysctl_test_clean() }}}

sed -i "/net.ipv4.conf.all.rp_filter/d" /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w net.ipv4.conf.all.rp_filter="1"
