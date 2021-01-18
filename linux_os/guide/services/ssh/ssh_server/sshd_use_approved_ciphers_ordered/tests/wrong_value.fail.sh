#!/bin/bash

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/# Ciphers aes128-ctr,aes192-ctr,weak-cipher,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc,rijndael-cbc@lysator\.liu\.se/" /etc/ssh/sshd_config
else
	echo "# Ciphers aes128-ctr,aes192-ctr,weak-cipher,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc,rijndael-cbc@lysator\.liu\.se" >> /etc/ssh/sshd_config
fi
