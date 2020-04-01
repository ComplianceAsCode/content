#!/bin/bas
# platform = Red Hat Enterprise Linux 7

# Removes ipv6.disable argument from kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX=.*ipv6\.disable=.*"'  '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)ipv6\.disable=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'
fi
