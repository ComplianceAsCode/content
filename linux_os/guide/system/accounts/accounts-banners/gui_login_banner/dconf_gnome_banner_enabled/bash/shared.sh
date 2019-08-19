# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol


{{{ dconf_settings("org/gnome/login-screen", "banner-message-enable", "true", "gdm.d", "00-security-settings") }}}
{{{ dconf_lock("org/gnome/login-screen", "banner-message-enable", "gdm.d", "00-security-settings-lock") }}}
