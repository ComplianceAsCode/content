# platform = multi_platform_all

dconf_login_banner_contents=$(echo "(bash-populate dconf_login_banner_contents)" )
{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-text", "'${dconf_login_banner_contents}'", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "banner-message-text", dconf_gdm_dir, "00-security-settings-lock") }}}
