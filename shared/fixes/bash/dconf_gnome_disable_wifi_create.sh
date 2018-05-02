# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/nm-applet' 'disable-wifi-create' 'true' 'local.d' '00-security-settings'
dconf_lock 'org/gnome/nm-applet' 'disable-wifi-create' 'local.d' '00-security-settings-lock'
