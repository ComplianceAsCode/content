# platform = multi_platform_all

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}
{{{ bash_dconf_lock("org/gnome/desktop/session", "idle-delay", dconf_gdm_dir, "00-security-settings-lock") }}}
