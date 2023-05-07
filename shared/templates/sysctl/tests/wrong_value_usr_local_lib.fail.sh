#!/bin/bash
{{% if SYSCTLVAL == "" %}}
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}
{{% endif %}}

{{{ bash_sysctl_test_clean() }}}

{{{ bash_sysctl_set_config_directories('sysctl_directories') }}}
for d in "${sysctl_directories[@]}"; do
if [[ "${d}" == /usr/local/lib/sysctl.d ]]; then
sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf
echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_WRONG_VALUE }}}" >> /usr/local/lib/sysctl.d/wrong.conf

# Setting correct runtime value
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
fi
done
