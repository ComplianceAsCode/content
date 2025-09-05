#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/# ciphers aes256-ctr,aes192-ctr,aes128-ctr/" /etc/ssh/sshd_config
else
	echo "# ciphers aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
fi
