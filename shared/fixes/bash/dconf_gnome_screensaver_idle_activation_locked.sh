# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_lock 'org/gnome/desktop/screensaver' 'idle-activation-enabled' 'local.d' '00-security-settings-lock'
