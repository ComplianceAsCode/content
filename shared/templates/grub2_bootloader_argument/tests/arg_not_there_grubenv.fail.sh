#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = grub2,grubby

source common.sh

# Removes audit argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*{{{ARG_NAME}}}=.*'  "$file" ; then
	sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi

