#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# Removes ipv6.disable argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*ipv6\.disable=.*'  "$file" ; then
	sed -i 's/\(^.*\)ipv6\.disable=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi
