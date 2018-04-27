# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_settings 'org/gnome/Vino' 'authentication-methods' "['vnc']" 'local.d' '00-security-settings'
dconf_lock 'org/gnome/Vino' 'authentication-methods' 'local.d' '00-security-settings-lock'
