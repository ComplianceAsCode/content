#!/bin/bash

# make sure the file exist
touch /etc/systemd/system.conf

if grep -q "^CtrlAltDelBurstAction=" /etc/systemd/system.conf; then
	sed -i "s/^CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=poweroff-immediate/" /etc/systemd/system.conf
else
	echo "CtrlAltDelBurstAction=poweroff-immediate" >> /etc/systemd/system.conf
fi
