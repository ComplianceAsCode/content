# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_lock 'org/gnome/desktop/screensaver' 'lock-delay' 'local.d' '00-security-settings-lock'
