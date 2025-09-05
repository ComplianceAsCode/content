# platform = multi_platform_all

{{{ bash_instantiate_variables("inactivity_timeout_value") }}}

{{{ bash_dconf_settings("org/gnome/desktop/session", "idle-delay", "uint32 ${inactivity_timeout_value}", "local.d", "00-security-settings") }}}
