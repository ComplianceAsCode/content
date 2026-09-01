# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
{{% endif %}}

{{% if 'ubuntu' in product %}}
{{{ bash_dconf_settings("org/gnome/settings-daemon/plugins/media-keys", "logout", "@as []", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{%- else %}}
{{{ bash_dconf_settings("org/gnome/settings-daemon/plugins/media-keys", "logout", "['']", "local.d", "00-security-settings", rule_id=rule_id) }}}
{{%- endif %}}
{{{ bash_dconf_lock("org/gnome/settings-daemon/plugins/media-keys", "logout", "local.d", "00-security-settings-lock") }}}
