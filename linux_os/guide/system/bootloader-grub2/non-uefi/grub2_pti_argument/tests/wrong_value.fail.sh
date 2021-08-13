#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# Break the pti argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*pti=.*'  "$file" ; then
	# modify the GRUB command-line if an pti= arg already exists
	sed -i 's/\(^.*\)pti=[^[:space:]]*\(.*\)/\1 pti=off \2/'  "$file"
else
	# no pti=arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 pti=off/'  "$file"
fi
