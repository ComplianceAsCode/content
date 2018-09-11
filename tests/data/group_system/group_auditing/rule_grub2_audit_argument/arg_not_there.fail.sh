#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

# Removes audit argument from kernel command line
if grep -q '^GRUB_CMDLINE_LINUX=.*audit=.*"'  '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'
fi
