#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

# Break the audit argument in kernel command line in /boot/grub2/grub.cfg and /boot/grub2/grubenv
for file in "/boot/grub2/grub.cfg" "/boot/grub2/grubenv"; do
	if grep -q '^.*audit=.*'  "$file" ; then
		# modify the GRUB command-line if an audit= arg already exists
		sed -i 's/\(^.*\)audit=[^[:space:]]*\(.*\)/\1 audit=0 \2/'  "$file"
	else
		# no audit=arg is present, append it
		sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 audit=0/'  "$file"
	fi
done
