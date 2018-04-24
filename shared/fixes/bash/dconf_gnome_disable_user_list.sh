# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_settings 'org/gnome/login-screen' 'disable-user-list' "true" 'gdm.d' '00-security-settings'
dconf_lock 'org/gnome/login-screen' 'disable-user-list' 'gdm.d' '00-security-settings-lock'
