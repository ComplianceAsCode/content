# platform = multi_platform_ubuntu

{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}

dconf_login_banner_contents=$(echo "(bash-populate dconf_login_banner_contents)" )
# Will do both approach, since we plan to migrate to checks over dconf db. That way, future updates of the tool
# will pass the check even if we decide to check only for the dconf db path.
{{{ set_config_file("/etc/gdm3/greeter.dconf-defaults", "banner-message-text", value="'${dconf_login_banner_contents}'", create='no', insert_after="\[org/gnome/login-screen\]", insert_before="", separator="=", separator_regex="", prefix_regex="^\s*", rule_id=rule_id) }}}
{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-text", "'${dconf_login_banner_contents}'", dconf_gdm_dir, "00-security-settings", rule_id=rule_id) }}}
# No need to use dconf update, since bash_dconf_settings does that already
