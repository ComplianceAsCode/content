#!/bin/bash

# Correct the form of default kernel command line in GRUB /etc/default/grub and applies value through Grubby
if grep -q '^GRUB_CMDLINE_LINUX=.*audit=.*"'  '/etc/default/grub' ; then
	# modify the GRUB command-line if an audit= arg already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit=[^[:space:]]*\(.*"\)/\1 audit=1 \2/'  '/etc/default/grub'
else
	# no audit=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 audit=1"/'  '/etc/default/grub'
fi

grubby --update-kernel=ALL --args="audit=1"
