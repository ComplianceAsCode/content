# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/login-screen' 'enable-smartcard-authentication' 'true' 'gdm.d' '00-security-settings'
dconf_lock 'org/gnome/login-screen' 'enable-smartcard-authentication' 'gdm.d' '00-security-settings-lock'
