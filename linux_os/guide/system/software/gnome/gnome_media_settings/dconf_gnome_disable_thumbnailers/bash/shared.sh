# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/desktop/thumbnailers", "disable-all", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/thumbnailers", "disable-all", "local.d", "00-security-settings-lock") }}}
