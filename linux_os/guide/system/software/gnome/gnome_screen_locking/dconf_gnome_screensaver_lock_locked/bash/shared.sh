# platform = multi_platform_all

{{% if product in ['opensuse16', 'sle15', 'sle16'] %}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-enabled", dconf_gdm_dir, "00-security-settings-lock") }}}
{{% else %}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-enabled", "local.d", "00-security-settings-lock") }}}
{{% endif %}}
