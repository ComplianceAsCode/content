#!/bin/bash

mkdir -p "{{{ sshd_config_dir }}}"
touch "{{{ sshd_config_dir }}}/nothing"

{{% if product in ['opensuse16', 'sle16', 'slmicro6'] %}}
    {{{ bash_copy_distro_defaults("/usr/etc/ssh/sshd_config", sshd_main_config_file) }}}
    {{{ lineinfile_absent(sshd_main_config_file, "^\s*Include\s*/usr/etc/ssh/sshd_config\.d/\*\.conf", sed_path_separator="#", rule_id=rule_id) }}}
{{% endif %}}

declare -a SSHD_PATHS=({{{ sshd_main_config_file }}} {{{ sshd_config_dir }}}/*)

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
	sed -i "s/^{{{ PARAMETER }}}.*/# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}/g" "${SSHD_PATHS[@]}"
else
	echo "# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> "{{{ sshd_main_config_file }}}"
fi
