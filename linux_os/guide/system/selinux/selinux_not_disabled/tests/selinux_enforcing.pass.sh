#!/bin/bash

SELINUX_FILE='/etc/selinux/config'
touch "$SELINUX_FILE"

if grep -s '^[[:space:]]*SELINUX' $SELINUX_FILE; then
	sed -i 's/^\([[:space:]]*SELINUX[[:space:]]*=[[:space:]]*\).*/\1enforcing/' $SELINUX_FILE
else
	echo 'SELINUX=enforcing' >> $SELINUX_FILE
fi
