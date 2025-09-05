# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("login_banner_text") }}}

# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
{{{ bash_deregexify_banner_anchors("login_banner_text") }}}
# 1 - Keep only the first banners if there are multiple
#    (dod_banners contains the long and short banner)
{{{ bash_deregexify_multiple_banners("login_banner_text") }}}
# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
{{{ bash_deregexify_banner_space("login_banner_text") }}}
# 3 - Adds newline "tokens". (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "(n)*")
{{{ bash_deregexify_banner_newline("login_banner_text", "(n)*") }}}
# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
{{{ bash_deregexify_banner_backslash("login_banner_text") }}}
# 5 - Removes the newline "token." (Transforms them into newline escape sequences "\n").
#    ( Needs to be done after 4, otherwise the escapce sequence will become just "n".
{{{ bash_deregexify_banner_newline_token("login_banner_text")}}}

{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}

# Will do both approach, since we plan to migrate to checks over dconf db. That way, future updates of the tool
# will pass the check even if we decide to check only for the dconf db path.
{{{ set_config_file("/etc/gdm3/greeter.dconf-defaults", "banner-message-text", value="'${login_banner_text}'", create='no', insert_after="\[org/gnome/login-screen\]", insert_before="", separator="=", separator_regex="", prefix_regex="^\s*") }}}
{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-text", "'${login_banner_text}'", dconf_gdm_dir, "00-security-settings") }}}
# No need to use dconf update, since bash_dconf_settings does that already
