# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol


{{{ bash_dconf_settings("org/gnome/Vino", "require-encryption", "true", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/Vino", "require-encryption", "local.d", "00-security-settings-lock") }}}
