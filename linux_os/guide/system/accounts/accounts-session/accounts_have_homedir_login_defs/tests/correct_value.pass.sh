#!/bin/bash
#

if grep -q "^CREATE_HOME" /etc/login.defs; then
	sed -i "s/^CREATE_HOME.*/CREATE_HOME yes/" /etc/login.defs
else
	echo "CREATE_HOME yes" >> /etc/login.defs
fi
