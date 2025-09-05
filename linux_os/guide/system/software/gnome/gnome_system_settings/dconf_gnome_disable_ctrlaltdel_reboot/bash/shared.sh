# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/settings-daemon/plugins/media-keys' 'logout' "string ''" 'local.d' '00-security-settings'
dconf_lock 'org/gnome/settings-daemon/plugins/media-keys' 'logout' 'local.d' '00-security-settings-lock'
