# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
# Duplicate the setting also in 'greeter.dconf-defaults' for consistency with
# 'dconf_gnome_login_banner_text' and better alignment with STIG V1R1.
{{{ set_config_file("/etc/gdm3/greeter.dconf-defaults", "banner-message-enable", value="true", create='no', insert_after="\[org/gnome/login-screen\]", insert_before="", separator="=", separator_regex="", prefix_regex="^\s*") }}}
{{% endif %}}

{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-enable", "true", dconf_gdm_dir, "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "banner-message-enable", dconf_gdm_dir, "00-security-settings-lock") }}}
