#!/bin/bash

# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# packages = grub2,grubby

source common.sh

# Removes argument from kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX=.*{{{ARG_NAME}}}=.*"'  '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\){{{ARG_NAME}}}=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'
fi

