#!/bin/bash
# variables = var_sshd_set_maxstartups=10:30:60

if grep -q "^MaxStartups" /etc/ssh/sshd_config; then
	sed -i "s/^MaxStartups.*/MaxStartups 5:60:30/" /etc/ssh/sshd_config
else
	echo "MaxStartups 5:60:30" >> /etc/ssh/sshd_config
fi
