#!/bin/bash

touch /etc/systemd/system.conf

if grep -q "^CtrlAltDelBurstAction=" /etc/systemd/system.conf; then
	sed -i "s/^CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=none/" /etc/systemd/system.conf
else
	echo "CtrlAltDelBurstAction=none" >> /etc/systemd/system.conf
fi
