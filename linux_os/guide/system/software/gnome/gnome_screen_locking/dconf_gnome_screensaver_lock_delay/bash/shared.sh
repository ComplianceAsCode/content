# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-delay", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% endif %}}

# apply fix for enable_dconf_user_profile, OVAL checks it
{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-delay", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% endif %}}

{{{ bash_instantiate_variables("var_screensaver_lock_delay") }}}

{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-delay", "uint32 ${var_screensaver_lock_delay}",dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
