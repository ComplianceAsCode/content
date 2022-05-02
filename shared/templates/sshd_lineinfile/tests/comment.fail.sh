#!/bin/bash

SSHD_PARAM={{{ PARAMETER }}}
SSHD_VAL={{{ VALUE }}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "s/^${SSHD_PARAM}.*/# ${SSHD_PARAM} ${SSHD_VAL}/g" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
else
	echo "# ${SSHD_PARAM} ${SSHD_VAL}" >> /etc/ssh/sshd_config
fi
