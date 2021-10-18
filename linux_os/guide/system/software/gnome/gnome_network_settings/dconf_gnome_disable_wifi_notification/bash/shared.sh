# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/nm-applet", "suppress-wireless-networks-available", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/nm-applet", "suppress-wireless-networks-available", "local.d", "00-security-settings-lock") }}}
