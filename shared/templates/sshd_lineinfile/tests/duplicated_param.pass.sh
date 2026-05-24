#!/bin/bash

declare -a SSHD_PATHS=("{{{ sshd_main_config_file }}}" "{{{ sshd_config_dir }}}/*")

mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
    sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "${SSHD_PATHS[@]}"
fi

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/ssh/sshd_config
echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/ssh/sshd_config
