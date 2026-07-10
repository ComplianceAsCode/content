#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10,SUSE Linux Enterprise 16,multi_platform_fedora,multi_platform_ubuntu

mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"

{{% if product in ["ol8", "ol9"] %}}
{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "/etc/ssh/sshd_config.d/*.conf", "%s %s", cce_identifiers=cce_identifiers) }}}
{{% endif %}}

declare -a SSHD_PATHS=("{{{ sshd_main_config_file }}}" "{{{ sshd_config_dir }}}/*")

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
    sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "${SSHD_PATHS[@]}"
fi

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

{{% if product in ["sle16", "slmicro6"] %}}
touch "{{{ sshd_main_config_file }}}"
{{% endif %}}

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> "{{{ sshd_config_dir }}}/first.conf"
echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> "{{{ sshd_config_dir }}}/second.conf"
