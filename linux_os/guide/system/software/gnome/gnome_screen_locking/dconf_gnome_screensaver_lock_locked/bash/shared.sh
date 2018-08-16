# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_lock 'org/gnome/desktop/screensaver' 'lock-enabled' 'local.d' '00-security-settings-lock'
