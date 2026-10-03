# platform = multi_platform_all

{{% if product in ['opensuse16', 'sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}
{{{ bash_dconf_settings("org/gnome/login-screen", "disable-restart-buttons", "true", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "disable-restart-buttons", dconf_gdm_dir, "00-security-settings-lock") }}}
