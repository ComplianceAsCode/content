# platform =  McAfee VirusScan Enterprise for Linux


NAILS_CONFIG_FILE="/var/opt/NAI/LinuxShield/etc/nailsd.cfg"
{{{ bash_replace_or_append("$NAILS_CONFIG_FILE", '^nailsd.oasEnabled', 'true', '@CCENUM@', '%s: %s') }}}
