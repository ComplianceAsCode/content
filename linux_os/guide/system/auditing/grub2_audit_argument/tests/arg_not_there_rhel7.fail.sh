#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Red Hat Enterprise Linux 7
# Removes audit argument from kernel command line in /boot/grub2/grub.cfg
file="/boot/grub2/grub.cfg"
if grep -q '^.*audit=.*'  "$file" ; then
	sed -i 's/\(^.*\)audit=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi
