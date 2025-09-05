# platform =  McAfee VirusScan Enterprise for Linux

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

NAILS_CONFIG_FILE="/var/opt/NAI/LinuxShield/etc/nailsd.cfg"
replace_or_append "$NAILS_CONFIG_FILE" '^nailsd.profile.OAS.action.Default.secondary' 'Quarantine' '@CCENUM@' '%s: %s'
