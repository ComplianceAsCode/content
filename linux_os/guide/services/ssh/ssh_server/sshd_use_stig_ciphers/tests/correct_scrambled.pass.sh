#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers aes192-ctr,aes128-ctr,aes256-ctr/" /etc/ssh/sshd_config
else
	echo "Ciphers aes192-ctr,aes128-ctr,aes256-ctr" >> /etc/ssh/sshd_config
fi
