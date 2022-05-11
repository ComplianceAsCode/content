#!/bin/bash
{{% if SYSCTLVAL == "" %}}
{{% if DATATYPE=="int" %}}
{{% set VALUE="0" %}}
{{% elif DATATYPE=="string" %}}
{{% set VALUE="correct_value" %}}
{{% endif %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ VALUE }}}

{{% else %}}
{{% set VALUE=SYSCTLVAL %}}
{{% endif %}}

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ VALUE }}}" >> /etc/sysctl.conf

# Put a config file out of the default dirs
echo "{{{ SYSCTLVAR }}} = {{{ VALUE }}}" >> /root/root-sysctl.conf

# Add a symlink
ln -s /root/root-sysctl.conf /etc/sysctl.d/90-root.conf

sysctl -w {{{ SYSCTLVAR }}}={{{ VALUE }}}
