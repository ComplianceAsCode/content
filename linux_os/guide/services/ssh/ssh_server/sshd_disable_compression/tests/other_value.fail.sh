#!/bin/bash

if grep -q "^Compression" /etc/ssh/sshd_config; then
	sed -i "s/^Compression.*/Compression delayed/" /etc/ssh/sshd_config
else
	echo "Compression delayed" >> /etc/ssh/sshd_config
fi
