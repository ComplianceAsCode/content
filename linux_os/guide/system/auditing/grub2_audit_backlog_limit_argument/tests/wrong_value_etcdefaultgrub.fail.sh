#!/bin/bash
# platform = Red Hat Enterprise Linux 7

# Break the audit_backlog_limit argument in kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX=.*audit_backlog_limit=.*"'  '/etc/default/grub' ; then
	# modify the GRUB command-line if an audit_backlog_limit= arg already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit_backlog_limit=[^[:space:]]*\(.*"\)/\1 audit_backlog_limit=123 \2/'  '/etc/default/grub'
else
	# no audit_backlog_limit=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 audit_backlog_limit=123"/'  '/etc/default/grub'
fi
