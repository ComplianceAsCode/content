# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/login-screen' 'allowed-failures' "3" 'gdm.d' '00-security-settings'
dconf_lock 'org/gnome/login-screen' 'allowed-failures' 'gdm.d' '00-security-settings-lock'
