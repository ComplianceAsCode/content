#!/bin/bash
# platform = Red Hat Enterprise Linux 7

# Removes ipv6.disable argument from kernel command line in /boot/grub2/grub.cfg
file="/boot/grub2/grub.cfg"
if grep -q '^.*ipv6\.disable=.*'  "$file" ; then
	sed -i 's/\(^.*\)ipv6\.disable=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi
