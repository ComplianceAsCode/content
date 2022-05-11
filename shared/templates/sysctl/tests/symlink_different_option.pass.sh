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

# Ensure a different sysctl option is configured
{{% if SYSCTLVAR != "net.ipv4.conf.all.accept_source_route" %}}
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/90-test.conf
{{% else %}}
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.d/90-test.conf
{{% endif %}}

# Add a symlink
ln -s /etc/sysctl.d/90-test.conf /etc/sysctl.d/99-sysctl.conf

sysctl -w {{{ SYSCTLVAR }}}={{{ VALUE }}}
