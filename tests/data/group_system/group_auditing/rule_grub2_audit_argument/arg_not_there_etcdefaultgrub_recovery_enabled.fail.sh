#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

# Removes audit argument from kernel command line in /etc/default/grub
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*audit=.*"'  '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)audit=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'
fi

# removing the parameter from the no recovery kernel parameters as well
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'

# enabling recovery
sed -i 's/\(^.*GRUB_DISABLE_RECOVERY=\).*/\1false/' '/etc/default/grub'
