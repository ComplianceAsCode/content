# platform =  McAfee VirusScan Enterprise for Linux

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

NAILS_CONFIG_FILE="/var/opt/NAI/LinuxShield/etc/ods.cfg"

if  ! grep -q extensions.mode "$NAILS_CONFIG_FILE"; then
	sed -i '$a nailsd.profile.ODS_default.filter.extensions.mode: all' "$NAILS_CONFIG_FILE"

else
	replace_or_append "$NAILS_CONFIG_FILE" 'extensions.mode' 'all' '@CCENUM@' '%s: %s'
fi
