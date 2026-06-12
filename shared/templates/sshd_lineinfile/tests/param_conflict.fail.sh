#!/bin/bash

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}


mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"

declare -a SSHD_PATHS=("{{{ sshd_main_config_file }}}" "{{{ sshd_config_dir }}}/*")

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
	sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "${SSHD_PATHS[@]}"
fi

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> "{{{ sshd_main_config_file }}}"
echo "{{{ PARAMETER }}} {{{ WRONG_VALUE }}}" >> "{{{ sshd_main_config_file }}}"
