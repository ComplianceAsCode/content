# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions

include_dconf_settings

dconf_settings 'org/gnome/nm-applet' 'suppress-wireless-networks-available' 'true' 'local.d' '00-security-settings'
dconf_lock 'org/gnome/nm-applet' 'suppress-wireless-networks-available' 'local.d' '00-security-settings-lock'
