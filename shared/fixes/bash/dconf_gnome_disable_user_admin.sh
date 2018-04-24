# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_settings 'org/gnome/desktop/lockdown' 'user-administration-disabled' "true" 'local.d' '00-security-settings'
dconf_lock 'org/gnome/desktop/lockdown' 'user-administration-disabled' 'local.d' '00-security-settings-lock'
