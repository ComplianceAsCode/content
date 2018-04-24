# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

dconf_lock 'org/gnome/desktop/session' 'idle-delay' 'local.d' '00-security-settings-lock'
