#!/bin/bash

# platform = Fedora,Red Hat Enterprise Linux 9

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^PubkeyAuthentication" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "s/^PubkeyAuthentication.*/# PubkeyAuthentication no/" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
else
	echo "# PubkeyAuthentication no" >> /etc/ssh/sshd_config
fi

echo "PubkeyAuthentication no" > /etc/ssh/sshd_config.d/correct.conf
