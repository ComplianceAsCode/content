# platform =  McAfee VirusScan Enterprise for Linux


NAILS_CONFIG_FILE="/var/opt/NAI/LinuxShield/etc/ods.cfg"

if  ! grep -q extensions.mode "$NAILS_CONFIG_FILE"; then
	sed -i '$a nailsd.profile.ODS_default.filter.extensions.mode: all' "$NAILS_CONFIG_FILE"

else
	{{{ bash_replace_or_append("$NAILS_CONFIG_FILE", 'extensions.mode', 'all', '%s: %s') }}}
fi
