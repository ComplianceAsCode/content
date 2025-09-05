#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro

if grep -q "^MACs" /etc/ssh/sshd_config; then
	sed -i "s/^MACs.*/MACs hmac-sha2-512/" /etc/ssh/sshd_config
else
	echo "MACs hmac-sha2-512" >> /etc/ssh/sshd_config
fi
