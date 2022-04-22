#!/bin/bash

# platform = Red Hat Enterprise Linux 8

# Removes audit argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*{{{ARG_NAME}}}=.*'  "$file" ; then
	sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi

