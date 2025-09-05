#!/bin/bash

# platform = multi_platform_fedora,Red Hat Enterprise Linux 9

SSHD_PARAM="Compression"

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
   sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} no" > /etc/ssh/sshd_config.d/good_config.conf
echo "${SSHD_PARAM} yes" > /etc/ssh/sshd_config.d/bad_config.conf
