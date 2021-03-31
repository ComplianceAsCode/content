#!/bin/bash

if grep -q "^Compression" /etc/ssh/sshd_config; then
	sed -i "s/^Compression.*/Compression no/" /etc/ssh/sshd_config
else
	echo "Compression no" >> /etc/ssh/sshd_config
fi
