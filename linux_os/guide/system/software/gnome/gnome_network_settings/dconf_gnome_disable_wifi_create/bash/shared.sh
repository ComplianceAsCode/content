# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora


{{{ bash_dconf_settings("org/gnome/nm-applet", "disable-wifi-create", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/nm-applet", "disable-wifi-create", "local.d", "00-security-settings-lock") }}}
