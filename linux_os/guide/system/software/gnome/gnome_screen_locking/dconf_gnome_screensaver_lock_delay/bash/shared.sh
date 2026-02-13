# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-delay", "local.d", "00-security-settings-lock") }}}
{{% endif %}}

{{{ bash_instantiate_variables("var_screensaver_lock_delay") }}}

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-delay", dconf_gdm_dir, "00-security-settings-lock") }}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-delay", "uint32 ${var_screensaver_lock_delay}", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-delay", "uint32 ${var_screensaver_lock_delay}", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{% endif %}}
