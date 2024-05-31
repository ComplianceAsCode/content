# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}

{{{ bash_instantiate_variables("inactivity_timeout_value") }}}

{{{ bash_dconf_settings("org/gnome/desktop/session", "idle-delay", "uint32 ${inactivity_timeout_value}", "local.d", "00-security-settings") }}}
