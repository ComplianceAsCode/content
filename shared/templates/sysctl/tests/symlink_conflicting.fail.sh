#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

. $SHARED/sysctl.sh
sysctl_reset

sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /etc/sysctl.conf

# Configure the same sysctl option
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_WRONG_VALUE }}}" >> /etc/sysctl.d/90-test.conf

# and add a symlink
ln -s /etc/sysctl.d/90-test.conf /etc/sysctl.d/99-sysctl.conf

sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
