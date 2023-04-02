#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

. $SHARED/sysctl.sh
sysctl_reset

sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "# {{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
