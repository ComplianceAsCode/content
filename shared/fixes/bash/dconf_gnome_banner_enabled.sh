# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_settings 'org/gnome/login-screen' 'banner-message-enable' "true" 'gdm.d' '00-security-settings'
dconf_lock 'org/gnome/login-screen' 'banner-message-enable' 'gdm.d' '00-security-settings-lock'
