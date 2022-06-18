#!/bin/bash

# platform = multi_platform_fedora,Red Hat Enterprise Linux 9

source common.sh

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} ${SSHD_VAL}" > /etc/ssh/sshd_config.d/good_config.conf
echo "${SSHD_PARAM} bad_val" > /etc/ssh/sshd_config.d/bad_config.conf
