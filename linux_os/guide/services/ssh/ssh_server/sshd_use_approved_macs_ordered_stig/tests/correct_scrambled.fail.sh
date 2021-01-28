#!/bin/bash

if grep -q "^MACs" /etc/ssh/sshd_config; then
	sed -i "s/^MACs.*/MACs hmac-sha2-256,hmac-sha2-512/" /etc/ssh/sshd_config
else
	echo "MACs hmac-sha2-256,hmac-sha2-512" >> /etc/ssh/sshd_config
fi
