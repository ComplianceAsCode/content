# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8


{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "automount", "false", "local.d", "00-No-Automount") }}}
{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "automount-open", "false", "local.d", "00-No-Automount") }}}
{{{ bash_dconf_settings("org/gnome/desktop/media-handling", "autorun-never", "true", "local.d", "00-No-Automount") }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "automount", "local.d", "00-No-Automount") }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "automount-open", "local.d", "00-No-Automount") }}}
{{{ bash_dconf_lock("org/gnome/desktop/media-handling", "autorun-never", "local.d", "00-No-Automount") }}}
