#!/bin/bash
# platform = Red Hat Enterprise Linux 7

# Break the ipv6.disable argument in kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX=.*ipv6\.disable=.*"'  '/etc/default/grub' ; then
	# modify the GRUB command-line if an ipv6.disable= arg already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)ipv6\.disable=[^[:space:]]*\(.*"\)/\1 ipv6\.disable=0 \2/'  '/etc/default/grub'
else
	# no ipv6.disable=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 ipv6\.disable=0"/'  '/etc/default/grub'
fi
