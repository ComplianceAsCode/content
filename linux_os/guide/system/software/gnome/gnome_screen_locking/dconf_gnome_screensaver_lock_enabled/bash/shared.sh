# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}

{{% if 'sle' in product %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
gsettings set org.gnome.desktop.lockdown disable-lock-screen false
{{{ bash_dconf_settings("org/gnome/desktop/lockdown", "disable-lock-screen", "false", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/lockdown", "disable-lock-screen", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-enabled", "true", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-enabled", "local.d", "00-security-settings-lock") }}}
{{% endif %}}
