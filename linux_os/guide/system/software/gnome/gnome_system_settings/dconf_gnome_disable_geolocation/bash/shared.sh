# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8


{{{ bash_dconf_settings("org/gnome/system/location", "enabled", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_settings("org/gnome/clocks", "geolocation", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/system/location", "enabled", "local.d", "00-security-settings-lock") }}}
{{{ bash_dconf_lock("org/gnome/clocks", "geolocation", "local.d", "00-security-settings-lock") }}}
