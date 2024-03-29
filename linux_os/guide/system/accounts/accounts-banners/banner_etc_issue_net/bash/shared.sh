# platform = multi_platform_all

{{{ bash_instantiate_variables("remote_login_banner_text") }}}

# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
{{{ bash_deregexify_banner_anchors("remote_login_banner_text") }}}
# 1 - Keep only the first banners if there are multiple
#    (dod_banners contains the long and short banner)
{{{ bash_deregexify_multiple_banners("remote_login_banner_text") }}}
# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
{{{ bash_deregexify_banner_space("remote_login_banner_text") }}}
# 3 - Adds newlines. (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "\n")
{{{ bash_deregexify_banner_newline("remote_login_banner_text", "\\n") }}}
# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
{{{ bash_deregexify_banner_backslash("remote_login_banner_text") }}}
formatted=$(echo "$remote_login_banner_text" | fold -sw 80)

cat <<EOF >/etc/issue.net
$formatted
EOF
