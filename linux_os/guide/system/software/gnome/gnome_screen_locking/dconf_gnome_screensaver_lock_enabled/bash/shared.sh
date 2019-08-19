# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol


{{{ dconf_settings("org/gnome/desktop/screensaver", "lock-enabled", "true", "local.d", "00-security-settings") }}}
{{{ dconf_lock("org/gnome/desktop/screensaver", "lock-enabled", "local.d", "00-security-settings-lock") }}}
