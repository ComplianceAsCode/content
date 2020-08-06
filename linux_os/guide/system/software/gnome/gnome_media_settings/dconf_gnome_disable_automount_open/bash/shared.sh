# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora


{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "automount-open", "false", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "automount-open", "local.d", "00-security-settings-lock") }}}
