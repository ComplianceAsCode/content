# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol


{{{ bash_dconf_settings("org/gnome/login-screen", "allowed-failures", "3", "gdm.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "allowed-failures", "gdm.d", "00-security-settings-lock") }}}
