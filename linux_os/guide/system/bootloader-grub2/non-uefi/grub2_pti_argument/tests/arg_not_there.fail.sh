#!/bin/bash

# platform = Red Hat Enterprise Linux 8

# Removes pti argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*pti=.*'  "$file" ; then
	sed -i 's/\(^.*\)pti=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi
