#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

# Removes audit argument from kernel command line in /boot/grub2/grub.cfg and /boot/grub2/grubenv
for file in "/boot/grub2/grub.cfg" "/boot/grub2/grubenv"; do
	if grep -q '^.*audit=.*'  "$file" ; then
		sed -i 's/\(^.*\)audit=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
	fi
done
