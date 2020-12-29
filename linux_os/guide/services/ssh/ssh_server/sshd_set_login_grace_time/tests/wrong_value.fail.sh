#!/bin/bash
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^LoginGraceTime" $SSHD_CONFIG; then
	sed -i "s/^LoginGraceTime.*/LoginGraceTime 120/" $SSHD_CONFIG
else
	echo "LoginGraceTime 120" >> $SSHD_CONFIG
fi
