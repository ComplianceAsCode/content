#!/bin/bash

if grep -q "^MACs" /etc/ssh/sshd_config; then
	sed -i "s/^MACs.*/MACs /" /etc/ssh/sshd_config
else
	echo 'MACs ' >> /etc/ssh/sshd_config
fi
