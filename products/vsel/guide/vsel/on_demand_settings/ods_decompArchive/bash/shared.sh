# platform =  McAfee VirusScan Enterprise for Linux


NAILS_CONFIG_FILE="/var/opt/NAI/LinuxShield/etc/ods.cfg"
{{{ bash_replace_or_append("$NAILS_CONFIG_FILE", '^nailsd.profile.ODS.decompArchive', 'true', '%s: %s') }}}
