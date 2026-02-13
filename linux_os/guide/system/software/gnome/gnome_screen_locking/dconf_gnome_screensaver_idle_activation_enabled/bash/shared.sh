# platform = multi_platform_all

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "idle-activation-enabled", "true", dconf_gdm_dir , "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "idle-activation-enabled", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "idle-activation-enabled", "true", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "idle-activation-enabled", "local.d", "00-security-settings-lock") }}}
{{% endif %}}
