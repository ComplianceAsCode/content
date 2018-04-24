# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_settings 'org/gnome/Vino' 'require-encryption' "true" 'local.d' '00-security-settings'
dconf_lock 'org/gnome/Vino' 'require-encryption' 'local.d' '00-security-settings-lock'
