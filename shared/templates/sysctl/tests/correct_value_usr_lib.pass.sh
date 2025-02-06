#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

# Clean sysctl config directories
{{% if "ubuntu" in product %}}
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/* /etc/ufw/sysctl.conf
{{% else %}}
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*
{{% endif %}}

sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
mkdir -p /usr/lib/sysctl.d
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /usr/lib/sysctl.d/correct.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
