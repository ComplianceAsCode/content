#!/bin/bash

SSHD_PARAM={{{ PARAMETER }}}

mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"
declare -a SSHD_PATHS=({{{ sshd_main_config_file }}} {{{ sshd_config_dir }}}/*)

{{% if product in ['sle16', 'slmicro6'] %}}
touch "{{{ sshd_main_config_file }}}"
{{% endif %}}

if grep -q "^\s*${SSHD_PARAM}" "${SSHD_PATHS[@]}" ; then
    sed -i "/^\s*${SSHD_PARAM}.*/Id" "${SSHD_PATHS[@]}"
fi
