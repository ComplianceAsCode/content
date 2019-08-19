# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8


{{{ dconf_settings("org/gnome/desktop/thumbnailers", "disable-all", "true", "local.d", "00-security-settings") }}}
{{{ dconf_lock("org/gnome/desktop/thumbnailers", "disable-all", "local.d", "00-security-settings-lock") }}}
