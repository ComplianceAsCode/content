#!/bin/bash
{{% if product == 'rhel8' %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
{{% endif %}}

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/kernel.kptr_restrict/d" /etc/sysctl.conf
echo "kernel.kptr_restrict = 2" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w kernel.kptr_restrict="2"
