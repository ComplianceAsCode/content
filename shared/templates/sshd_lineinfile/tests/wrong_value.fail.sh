#!/bin/bash

source common.sh
SSHD_VAL="bad_val"

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} ${SSHD_VAL}" >> /etc/ssh/sshd_config
