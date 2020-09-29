#!/bin/bash
# platform = Red Hat Enterprise Linux 7

# Break the audit argument in kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*audit=.*"'  '/etc/default/grub' ; then
	# modify the GRUB command-line if an audit= arg already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)audit=[^[:space:]]*\(.*"\)/\1 audit=0 \2/'  '/etc/default/grub'
else
	# no audit=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 audit=0"/'  '/etc/default/grub'
fi

# removing the parameter from the no recovery kernel parameters as well
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'

# disabling recovery
sed -i 's/\(^.*GRUB_DISABLE_RECOVERY=\).*/\1true/' '/etc/default/grub'

#if the line is not present at all, add it
if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*$' '/etc/default/grub'; then
	echo 'GRUB_CMDLINE_LINUX_DEFAULT="audit=0"' >> /etc/default/grub
fi
