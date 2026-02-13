# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}

# apply fix for enable_dconf_user_profile, OVAL checks it
{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "automount", "false", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "automount", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "automount", "false", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "automount", "local.d", "00-security-settings-lock") }}}
{{% endif %}}
