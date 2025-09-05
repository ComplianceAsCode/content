#!/bin/bash
#
if grep -q "^UMASK" /etc/login.defs; then
	sed -i "s/^UMASK.*/UMASK 177/" /etc/login.defs
else
	echo "UMASK 177" >> /etc/login.defs
fi
