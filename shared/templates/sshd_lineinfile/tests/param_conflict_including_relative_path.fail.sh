#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

SSHD_PARAM={{{ PARAMETER }}}
SSHD_VAL={{{ VALUE }}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "sshd_config.d/*.conf", "%s %s") }}}

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} ${SSHD_VAL}" > /etc/ssh/sshd_config.d/good_config.conf
echo "${SSHD_PARAM} bad_val" > /etc/ssh/sshd_config.d/bad_config.conf
