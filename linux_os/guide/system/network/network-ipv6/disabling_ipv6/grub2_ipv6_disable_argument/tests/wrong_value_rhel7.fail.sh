#!/bin/bash
# platform = Red Hat Enterprise Linux 7

# Break the ipv6.disable argument in kernel command line in /boot/grub2/grub.cfg
file="/boot/grub2/grub.cfg"
if grep -q '^.*ipv6\.disable=.*'  "$file" ; then
	# modify the GRUB command-line if an ipv6.disable= arg already exists
	sed -i 's/\(^.*\)ipv6\.disable=[^[:space:]]*\(.*\)/\1 ipv6\.disable=0 \2/'  "$file"
else
	# no ipv6.disable=arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 ipv6\.disable=0/'  "$file"
fi

