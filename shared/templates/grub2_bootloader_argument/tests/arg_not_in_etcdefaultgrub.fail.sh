#!/bin/bash

# platform = multi_platform_all

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# Removes argument from kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX=.*{{{ARG_NAME}}}=.*"'  '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\){{{ARG_NAME}}}=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'
fi
