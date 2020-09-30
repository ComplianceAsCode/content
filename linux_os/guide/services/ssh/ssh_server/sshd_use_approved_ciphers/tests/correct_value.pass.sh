#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc/" /etc/ssh/sshd_config
else
	echo 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc' >> /etc/ssh/sshd_config
fi
