#!/bin/bash
{{%- if NO_REMEDIATION %}}
# remediation = none
{{%- endif -%}}
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
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /etc/sysctl.conf

# Put a config file out of the default dirs
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_WRONG_VALUE }}}" >> /root/root-sysctl.conf

# Add a symlink
ln -s /root/root-sysctl.conf /etc/sysctl.d/90-root.conf

sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
