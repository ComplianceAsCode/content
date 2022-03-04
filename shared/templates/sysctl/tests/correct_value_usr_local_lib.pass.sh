#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

{{{ bash_sysctl_test_clean() }}}

{{% if product not in ["sle12","sle15"] %}}
sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /usr/local/lib/sysctl.d/correct.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
{{% endif %}}
