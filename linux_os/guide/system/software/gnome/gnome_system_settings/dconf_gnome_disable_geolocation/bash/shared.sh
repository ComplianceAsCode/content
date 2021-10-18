# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/system/location", "enabled", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_settings("org/gnome/clocks", "geolocation", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/system/location", "enabled", "local.d", "00-security-settings-lock") }}}
{{{ bash_dconf_lock("org/gnome/clocks", "geolocation", "local.d", "00-security-settings-lock") }}}
