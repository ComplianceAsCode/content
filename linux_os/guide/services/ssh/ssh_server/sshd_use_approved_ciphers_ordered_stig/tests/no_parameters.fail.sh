#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers /" /etc/ssh/sshd_config
else
	echo 'Ciphers ' >> /etc/ssh/sshd_config
fi
