#!/bin/bash

SSHD_PARAM={{{ PARAMETER }}}
SSHD_VAL={{{ VALUE }}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} ${SSHD_VAL}" >> /etc/ssh/sshd_config
echo "${SSHD_PARAM} bad_val" >> /etc/ssh/sshd_config
