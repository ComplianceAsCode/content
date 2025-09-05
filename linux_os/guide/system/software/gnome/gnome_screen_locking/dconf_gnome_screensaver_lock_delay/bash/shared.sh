# platform = multi_platform_all

{{{ bash_instantiate_variables("var_screensaver_lock_delay") }}}

{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-delay", "uint32 ${var_screensaver_lock_delay}", "local.d", "00-security-settings") }}}
