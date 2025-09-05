# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/nm-applet", "disable-wifi-create", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/nm-applet", "disable-wifi-create", "local.d", "00-security-settings-lock") }}}
