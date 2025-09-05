#!/bin/bash

# platform = Red Hat Enterprise Linux 7

# Removes audit argument from kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX=.*audit=.*"'  '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'
fi
