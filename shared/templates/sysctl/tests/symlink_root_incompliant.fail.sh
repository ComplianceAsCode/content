#!/bin/bash
{{% if SYSCTLVAL == "" %}}
{{% if DATATYPE=="int" %}}
{{% set VALUE="0" %}}
{{% set WRONG_VALUE="1" %}}
{{% elif DATATYPE=="string" %}}
{{% set VALUE="correct_value" %}}
{{% set WRONG_VALUE="wrong_value" %}}
{{% endif %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ VALUE }}}

{{% else %}}
{{% set VALUE=SYSCTLVAL %}}
{{% if DATATYPE=="int" %}}
{{% set WRONG_VALUE="1"~SYSCTLVAL %}}
{{% elif DATATYPE=="string" %}}
{{% set WRONG_VALUE="wrong_value" %}}
{{% endif %}}
{{% endif %}}

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ VALUE }}}" >> /etc/sysctl.conf

# Put a config file out of the default dirs
echo "{{{ SYSCTLVAR }}} = {{{ WRONG_VALUE }}}" >> /root/root-sysctl.conf

# Add a symlink
ln -s /root/root-sysctl.conf /etc/sysctl.d/90-root.conf

sysctl -w {{{ SYSCTLVAR }}}={{{ VALUE }}}
