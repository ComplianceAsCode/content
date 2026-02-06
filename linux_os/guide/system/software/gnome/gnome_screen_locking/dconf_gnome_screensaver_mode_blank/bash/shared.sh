# platform = multi_platform_all

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "picture-uri", "string ''", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "picture-uri", dconf_gdm_dir, "00-security-settings-lock") }}}
