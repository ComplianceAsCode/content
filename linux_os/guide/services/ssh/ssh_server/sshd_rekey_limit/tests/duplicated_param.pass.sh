#!/bin/bash

SSHD_PARAM="RekeyLimit"

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
    sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} 512M 1h" >> /etc/ssh/sshd_config
echo "${SSHD_PARAM} 512M 1h" >> /etc/ssh/sshd_config

