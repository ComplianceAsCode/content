# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/login-screen' 'disable-user-list' 'true' 'gdm.d' '00-security-settings'
dconf_lock 'org/gnome/login-screen' 'disable-user-list' 'gdm.d' '00-security-settings-lock'
