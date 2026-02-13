# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/session", "idle-delay", "local.d", "00-security-settings-lock") }}}
{{% endif %}}

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/session", "idle-delay", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% endif %}}

{{{ bash_instantiate_variables("inactivity_timeout_value") }}}

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_dconf_settings("org/gnome/desktop/session", "idle-delay", "uint32 ${inactivity_timeout_value}", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/session", "idle-delay", "uint32 ${inactivity_timeout_value}", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{% endif %}}
