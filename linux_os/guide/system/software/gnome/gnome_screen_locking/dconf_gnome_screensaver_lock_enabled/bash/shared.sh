# platform = multi_platform_all

{{% if 'sle' in product %}}
gsettings set org.gnome.desktop.lockdown disable-lock-screen false
{{{ bash_dconf_settings("org/gnome/desktop/lockdown", "disable-lock-screen", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/lockdown", "disable-lock-screen", "local.d", "00-security-settings-lock") }}}
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-enabled", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-enabled", "local.d", "00-security-settings-lock") }}}
{{% endif %}}
