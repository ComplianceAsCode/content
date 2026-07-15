#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10,SUSE Linux Enterprise 16,multi_platform_fedora,multi_platform_ubuntu


{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"

declare -a SSHD_PATHS=({{{ sshd_main_config_file }}} {{{ sshd_config_dir }}}/*)

{{% if product in ["ol8", "ol9"] %}}
{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "/etc/ssh/sshd_config.d/*.conf", "%s %s", cce_identifiers=cce_identifiers) }}}
{{% endif %}}

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}"; then
	sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "${SSHD_PATHS[@]}"
fi

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" > "{{{ sshd_config_dir }}}/good_config.conf"
echo "{{{ PARAMETER }}} {{{ WRONG_VALUE }}}" > "{{{ sshd_config_dir }}}/bad_config.conf"
