#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /etc/sysctl.conf

# Multiple symliks to the same file should be ignored
ln -s /etc/sysctl.conf /etc/sysctl.d/90-sysctl.conf
ln -s /etc/sysctl.conf /etc/sysctl.d/99-sysctl.conf

sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"

