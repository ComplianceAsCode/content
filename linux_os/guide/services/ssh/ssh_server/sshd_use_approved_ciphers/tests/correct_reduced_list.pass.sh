#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers aes128-ctr,aes192-ctr/" /etc/ssh/sshd_config
else
	echo "Ciphers aes128-ctr,aes192-ctr" >> /etc/ssh/sshd_config
fi
