#!/bin/bash
# platform = multi_platform_sle
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

{{{ bash_sysctl_test_clean() }}}

{{{ bash_sysctl_set_config_directories('sysctl_directories') }}}
for d in "${sysctl_directories[@]}"; do
if [[ "${d}" == /usr/local/lib/sysctl.d ]]; then
sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /usr/local/lib/sysctl.d/correct.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
fi
done
