#!/bin/bash
#
# variables = var_sshd_priv_separation=sandbox

if grep -q "^UsePrivilegeSeparation" /etc/ssh/sshd_config; then
	sed -i "s/^UsePrivilegeSeparation.*/# UsePrivilegeSeparation sandbox/" /etc/ssh/sshd_config
else
	echo "# UsePrivilegeSeparation sandbox" >> /etc/ssh/sshd_config
fi

