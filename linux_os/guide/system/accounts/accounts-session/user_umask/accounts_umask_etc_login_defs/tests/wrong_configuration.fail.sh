#!/bin/bash
#
{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

if grep -q "^UMASK" "$LOGIN_DEFS_PATH"; then
	sed -i "s/^UMASK.*/umask 077/" "$LOGIN_DEFS_PATH"
else
	echo "umask 077" >> "$LOGIN_DEFS_PATH"
fi
