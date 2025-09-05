# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/Vino' 'require-encryption' 'true' 'local.d' '00-security-settings'
dconf_lock 'org/gnome/Vino' 'require-encryption' 'local.d' '00-security-settings-lock'
