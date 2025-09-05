# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol


{{{ bash_dconf_settings("org/gnome/Vino", "authentication-methods", "['vnc']", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/Vino", "authentication-methods", "local.d", "00-security-settings-lock") }}}
