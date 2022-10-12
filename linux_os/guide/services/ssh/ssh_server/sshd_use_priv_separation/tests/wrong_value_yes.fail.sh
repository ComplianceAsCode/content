#!/bin/bash
#
# variables = var_sshd_priv_separation=sandbox

if grep -q "^UsePrivilegeSeparation" /etc/ssh/sshd_config; then
	sed -i "s/^UsePrivilegeSeparation.*/UsePrivilegeSeparation yes/" /etc/ssh/sshd_config
else
	echo "UsePrivilegeSeparation yes" >> /etc/ssh/sshd_config
fi
