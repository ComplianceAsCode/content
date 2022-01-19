#!/bin/bash
#
if grep -q "^UMASK" /etc/login.defs; then

	sed -i "s/^UMASK.*/UMASK 077/" /etc/login.defs
else
	echo "UMASK 077" >> /etc/login.defs
fi
