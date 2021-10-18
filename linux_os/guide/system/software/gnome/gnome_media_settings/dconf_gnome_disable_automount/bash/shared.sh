# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "automount", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "automount", "local.d", "00-security-settings-lock") }}}
