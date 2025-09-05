# platform =  McAfee VirusScan Enterprise for Linux

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

NAILS_CONFIG_FILE="/var/opt/NAI/LinuxShield/etc/ods.cfg"
replace_or_append "$NAILS_CONFIG_FILE" '^nailsd.profile.ODS.action.App.secondary' 'Quarantine' '@CCENUM@' '%s: %s'
