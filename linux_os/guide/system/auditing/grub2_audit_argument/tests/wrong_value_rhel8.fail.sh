#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# Break the audit argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*audit=.*'  "$file" ; then
	# modify the GRUB command-line if an audit= arg already exists
	sed -i 's/\(^.*\)audit=[^[:space:]]*\(.*\)/\1 audit=0 \2/'  "$file"
else
	# no audit=arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 audit=0/'  "$file"
fi
