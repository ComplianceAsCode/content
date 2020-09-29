#!/bin/bash
#

if grep -q "^UMASK" /etc/login.defs; then
	sed -i "s/^UMASK.*/UMASK 027/" /etc/login.defs
else
	echo "UMASK 027" >> /etc/login.defs
fi
