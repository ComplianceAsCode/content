#!/bin/bash

SELINUX_FILE='/etc/selinux/config'
touch "$SELINUX_FILE"

if grep -s '^[[:space:]]*SELINUX' $SELINUX_FILE; then
	sed -i 's/^\([[:space:]]*SELINUX[[:space:]]*=[[:space:]]*\).*/\1disabled/' $SELINUX_FILE
else
	echo 'SELINUX=disabled' >> $SELINUX_FILE
fi
