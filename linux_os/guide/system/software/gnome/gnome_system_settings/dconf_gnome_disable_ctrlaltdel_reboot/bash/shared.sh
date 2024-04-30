# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/settings-daemon/plugins/media-keys", "logout", "['']", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/settings-daemon/plugins/media-keys", "logout", "local.d", "00-security-settings-lock") }}}
