#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = grub2,grubby

source common.sh

# Break the argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*{{{ARG_NAME}}}=.*'  "$file" ; then
	# modify the GRUB command-line if the arg already exists
	sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 {{{ARG_NAME}}}=wrong \2/'  "$file"
else
	# no arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ARG_NAME}}}=wrong/'  "$file"
fi
