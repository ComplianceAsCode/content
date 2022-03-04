#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

{{{ bash_sysctl_test_clean() }}}

{{% if product not in ["sle12","sle15"] %}}
sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_WRONG_VALUE }}}" >> /usr/local/lib/sysctl.d/wrong.conf

# Setting correct runtime value
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
{{% endif %}}
