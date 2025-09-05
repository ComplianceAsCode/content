#!/bin/bash

# platform = Red Hat Enterprise Linux 8

# Removes audit argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*audit=.*'  "$file" ; then
	sed -i 's/\(^.*\)audit=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi
