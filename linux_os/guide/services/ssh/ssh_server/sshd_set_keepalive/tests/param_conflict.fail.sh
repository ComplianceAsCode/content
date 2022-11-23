#!/bin/bash
# variables = var_sshd_set_keepalive=1

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*ClientAliveCountMax" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*ClientAliveCountMax.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 1" >> /etc/ssh/sshd_config
