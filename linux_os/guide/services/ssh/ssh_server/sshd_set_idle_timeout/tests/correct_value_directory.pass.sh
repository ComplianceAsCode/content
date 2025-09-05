#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 9

SSHD_CONFIG_DIR="/etc/ssh/sshd_config.d"
SSHD_CONFIG="${SSHD_CONFIG_DIR}/good_config.conf"

mkdir -p $SSHD_CONFIG_DIR
touch $SSHD_CONFIG

if grep -q "^\s*ClientAliveInterval" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
    sed -i "/^\s*ClientAliveInterval.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi
if grep -q "^\s*ClientAliveCountMax" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
    sed -i "/^\s*ClientAliveCountMax.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "ClientAliveInterval 200" >> $SSHD_CONFIG
echo "ClientAliveCountMax 0" >> $SSHD_CONFIG
