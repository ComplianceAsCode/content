#!/bin/bash

CONFIRM_SPAWN_OPT="systemd.confirm_spawn"
CONFIRM_SPAWN_YES="systemd.confirm_spawn=yes"

if grep -q "^GRUB_CMDLINE_LINUX=" /etc/default/grub; then
	if grep -q "^GRUB_CMDLINE_LINUX=\".*${CONFIRM_SPAWN_OPT}.*\"" /etc/default/grub; then
		sed -i "s/${CONFIRM_SPAWN_OPT}=[^ \t]*/${CONFIRM_SPAWN_YES}/" /etc/default/grub
	else
		sed -i "s/\(^GRUB_CMDLINE_LINUX=.*\)\"$/\1 ${CONFIRM_SPAWN_YES}\"/" /etc/default/grub
	fi
else
	echo "GRUB_CMDLINE_LINUX=\"${CONFIRM_SPAWN_YES}\"" >> /etc/default/grub
fi

if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub; then
	if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=\".*${CONFIRM_SPAWN_OPT}.*\"" /etc/default/grub; then
		sed -i "s/${CONFIRM_SPAWN_OPT}=[^ \t]*/${CONFIRM_SPAWN_YES}/" /etc/default/grub
	else
		sed -i "s/\(^GRUB_CMDLINE_LINUX_DEFAULT=.*\)\"$/\1 ${CONFIRM_SPAWN_YES}\"/" /etc/default/grub
	fi
else
	echo "GRUB_CMDLINE_LINUX_DEFAULT=\"${CONFIRM_SPAWN_YES}\"" >> /etc/default/grub
fi
