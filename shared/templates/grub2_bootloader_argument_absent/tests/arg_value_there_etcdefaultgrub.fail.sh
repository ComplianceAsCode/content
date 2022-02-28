#!/bin/bash

# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# packages = grub2-tools,grubby

# Adds argument with a value from kernel command line in /etc/default/grub
if ! grep -q '^GRUB_CMDLINE_LINUX=.*{{{ARG_NAME}}}.*"' '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"$/\1 {{{ ARG_NAME }}}=1"/' '/etc/default/grub'
fi

