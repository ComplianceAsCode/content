#!/bin/bash
# variables = var_sshd_set_keepalive=1

SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^ClientAliveCountMax" $SSHD_CONFIG; then
	sed -i "s/^ClientAliveCountMax.*/# ClientAliveCountMax 1/" $SSHD_CONFIG
else
	echo "# ClientAliveCountMax 1" >> $SSHD_CONFIG
fi
