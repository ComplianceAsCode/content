# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux

{{{ bash_instantiate_variables("motd_banner_text") }}}

# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
{{{ bash_deregexify_banner_anchors("motd_banner_text") }}}
# 1 - Keep only the first banners if there are multiple
#    (dod_banners contains the long and short banner)
{{{ bash_deregexify_multiple_banners("motd_banner_text") }}}
# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
{{{ bash_deregexify_banner_space("motd_banner_text") }}}
# 3 - Adds newlines. (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "\n")
{{{ bash_deregexify_banner_newline("motd_banner_text", "\\n") }}}
# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
{{{ bash_deregexify_banner_backslash("motd_banner_text") }}}
formatted=$(echo "$motd_banner_text" | fold -sw 80)

cat <<EOF >/etc/motd
$formatted
EOF
