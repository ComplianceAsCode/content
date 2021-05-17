# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/login-screen", "allowed-failures", "3", dconf_gdm_dir, "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "allowed-failures", dconf_gdm_dir, "00-security-settings-lock") }}}
