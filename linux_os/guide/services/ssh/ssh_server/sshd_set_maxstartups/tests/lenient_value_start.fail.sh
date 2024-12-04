#!/bin/bash
# variables = var_sshd_set_maxstartups=10:30:60

if grep -q "^MaxStartups" /etc/ssh/sshd_config; then
	sed -i "s/^MaxStartups.*/MaxStartups 11:30:60/" /etc/ssh/sshd_config
else
	echo "MaxStartups 11:30:60" >> /etc/ssh/sshd_config
fi
