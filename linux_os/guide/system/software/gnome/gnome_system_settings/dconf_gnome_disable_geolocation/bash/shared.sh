# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8


{{{ dconf_settings("org/gnome/system/location", "enabled", "false", "local.d", "00-security-settings") }}}
{{{ dconf_settings("org/gnome/clocks", "geolocation", "false", "local.d", "00-security-settings") }}}
{{{ dconf_lock("org/gnome/system/location", "enabled", "local.d", "00-security-settings-lock") }}}
{{{ dconf_lock("org/gnome/clocks", "geolocation", "local.d", "00-security-settings-lock") }}}
