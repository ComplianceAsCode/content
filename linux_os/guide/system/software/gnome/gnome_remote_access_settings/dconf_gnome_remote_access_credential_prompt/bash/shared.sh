# platform = multi_platform_all

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}

{{{ bash_dconf_settings("org/gnome/Vino", "authentication-methods", "['vnc']", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/Vino", "authentication-methods", dconf_gdm_dir, "00-security-settings-lock") }}}
