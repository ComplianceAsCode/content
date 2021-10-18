# platform = multi_platform_all

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

{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-text", "'${login_banner_text}'", dconf_gdm_dir, "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "banner-message-text", dconf_gdm_dir, "00-security-settings-lock") }}}
