# platform = multi_platform_all

{{% if product in ['sle12','sle15'] %}}
gsettings set org.gnome.desktop.lockdown disable-lock-screen false
{{% else %}}
{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-enabled", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-enabled", "local.d", "00-security-settings-lock") }}}
{{% endif %}}
