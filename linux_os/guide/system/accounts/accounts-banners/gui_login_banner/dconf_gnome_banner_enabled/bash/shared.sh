# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}

{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-enable", "true", dconf_gdm_dir, "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "banner-message-enable", dconf_gdm_dir, "00-security-settings-lock") }}}
