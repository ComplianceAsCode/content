#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# Break the audit_backlog_limit argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*audit_backlog_limit=.*'  "$file" ; then
	# modify the GRUB command-line if an audit_backlog_limit= arg already exists
	sed -i 's/\(^.*\)audit_backlog_limit=[^[:space:]]*\(.*\)/\1 audit_backlog_limit=123 \2/'  "$file"
else
	# no audit_backlog_limit=arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 audit_backlog_limit=123/'  "$file"
fi
