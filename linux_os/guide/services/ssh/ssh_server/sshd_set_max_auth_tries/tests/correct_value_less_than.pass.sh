#!/bin/bash
SSHD_CONFIG="{{{ sshd_main_config_file }}}"

if grep -q "^MaxAuthTries" $SSHD_CONFIG; then
	sed -i "s/^MaxAuthTries.*/MaxAuthTries 2/" $SSHD_CONFIG
else
	echo "MaxAuthTries 2" >> $SSHD_CONFIG
fi
