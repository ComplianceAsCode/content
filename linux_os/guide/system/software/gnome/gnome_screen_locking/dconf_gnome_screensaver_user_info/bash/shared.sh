# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol


{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "show-full-name-in-top-bar", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "show-full-name-in-top-bar", "local.d", "00-security-settings-lock") }}}
