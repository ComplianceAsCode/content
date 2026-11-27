#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers aes128-ctr,aes128-gcm@openssh.com,aes256-ctr,aes256-gcm@openssh.com/" /etc/ssh/sshd_config
else
	echo "Ciphers aes128-ctr,aes128-gcm@openssh.com,aes256-ctr,aes256-gcm@openssh.com" >> /etc/ssh/sshd_config
fi
