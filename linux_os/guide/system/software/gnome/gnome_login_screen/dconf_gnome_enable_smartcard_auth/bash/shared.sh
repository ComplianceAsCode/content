# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol


{{{ bash_dconf_settings("org/gnome/login-screen", "enable-smartcard-authentication", "true", "gdm.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "enable-smartcard-authentication", "gdm.d", "00-security-settings-lock") }}}
