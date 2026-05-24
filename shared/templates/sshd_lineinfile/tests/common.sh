#!/bin/bash

mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"

declare -a SSHD_PATHS=("{{{ sshd_main_config_file }}}" "{{{ sshd_config_dir }}}/*")

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
	sed -i "s/^{{{ PARAMETER }}}.*/# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}/g" "${SSHD_PATHS[@]}"
else
	echo "# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> "{{{ sshd_main_config_file }}}"
fi
