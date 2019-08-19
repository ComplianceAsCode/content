# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol


{{{ dconf_settings("org/gnome/desktop/lockdown", "user-administration-disabled", "true", "local.d", "00-security-settings") }}}
{{{ dconf_lock("org/gnome/desktop/lockdown", "user-administration-disabled", "local.d", "00-security-settings-lock") }}}
