# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/login-screen", "disable-user-list", "true", dconf_gdm_dir, "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "disable-user-list", dconf_gdm_dir, "00-security-settings-lock") }}}
