#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers aes192-ctr,aes128-ctr/" /etc/ssh/sshd_config
else
	echo "Ciphers aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
fi
