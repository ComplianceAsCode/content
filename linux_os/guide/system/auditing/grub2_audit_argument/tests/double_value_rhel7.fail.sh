#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

# Break the audit argument in kernel command line in /boot/grub2/grub.cfg
file="/boot/grub2/grub.cfg"
if grep -q '^.*audit=.*'  "$file" ; then
	# modify the GRUB command-line if an audit= arg already exists
	sed -i 's/\(^.*\)audit=[^[:space:]]*\(.*\)/\1 audit=11 \2/'  "$file"
else
	# no audit=arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 audit=11/'  "$file"
fi

