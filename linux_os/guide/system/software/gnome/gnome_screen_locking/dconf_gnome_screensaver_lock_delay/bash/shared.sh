# platform = Red Hat Enterprise Linux 7, multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
populate var_screensaver_lock_delay

include_dconf_settings

dconf_settings 'org/gnome/desktop/screensaver' 'lock-delay' "uint32 ${var_screensaver_lock_delay}" 'local.d' '00-security-settings'
dconf_lock 'org/gnome/desktop/screensaver' 'lock-delay' 'local.d' '00-security-settings-lock'
