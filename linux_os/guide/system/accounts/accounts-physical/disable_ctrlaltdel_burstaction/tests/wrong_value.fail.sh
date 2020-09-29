#!/bin/bash


if grep -q "^CtrlAltDelBurstAction=" /etc/systemd/system.conf; then
	sed -i "s/^CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=poweroff-immediate/" /etc/systemd/system.conf
else
	echo "CtrlAltDelBurstAction=poweroff-immediate" >> /etc/systemd/system.conf
fi
