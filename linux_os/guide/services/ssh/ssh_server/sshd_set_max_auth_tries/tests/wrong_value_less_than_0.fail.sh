#!/bin/bash
# platform = multi_platform_all
# variables = sshd_max_auth_tries_value=4

SSHD_CONFIG="{{{ sshd_main_config_file }}}"

if grep -q "^MaxAuthTries" $SSHD_CONFIG; then
	sed -i "s/^MaxAuthTries.*/MaxAuthTries 0/" $SSHD_CONFIG
else
	echo "MaxAuthTries 0" >> $SSHD_CONFIG
fi
