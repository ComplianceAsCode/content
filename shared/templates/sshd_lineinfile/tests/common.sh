#!/bin/bash

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

declare -a SSHD_PATHS=("/etc/ssh/sshd_config" /etc/ssh/sshd_config.d/*)
{{% if product == 'sle16' %}}
SSHD_PATHS+=("/usr/etc/ssh/sshd_config" /usr/etc/ssh/sshd_config.d/*)
{{% endif %}}

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
	sed -i "s/^{{{ PARAMETER }}}.*/# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}/g" "${SSHD_PATHS[@]}"
else
	echo "# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/ssh/sshd_config
fi
