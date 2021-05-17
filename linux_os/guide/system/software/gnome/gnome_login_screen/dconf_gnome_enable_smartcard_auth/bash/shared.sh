# platform = multi_platform_all


{{{ bash_dconf_settings("org/gnome/login-screen", "enable-smartcard-authentication", "true", dconf_gdm_dir, "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "enable-smartcard-authentication", dconf_gdm_dir, "00-security-settings-lock") }}}
