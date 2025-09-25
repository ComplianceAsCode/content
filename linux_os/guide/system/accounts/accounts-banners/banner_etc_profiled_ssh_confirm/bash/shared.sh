# platform = multi_platform_all

{{{ bash_instantiate_variables("var_ssh_confirm_text") }}}

# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
{{{ bash_deregexify_banner_anchors("var_ssh_confirm_text") }}}
# 1 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
{{{ bash_deregexify_banner_space("var_ssh_confirm_text") }}}
# 2 - Adds newlines. (Transforms "(?:\[\n\]+|(?:\n)+)" into "\n")
{{{ bash_deregexify_banner_newline("var_ssh_confirm_text", "\\n") }}}
# 3 - Remove any leftover backslash. (From any parenthesis in the banner, for example).
{{{ bash_deregexify_banner_backslash("var_ssh_confirm_text") }}}
formatted=$(echo "$var_ssh_confirm_text")

OLD_UMASK=$(umask)
umask u=rw,go=r

cat <<EOF >/etc/profile.d/ssh_confirm.sh
$formatted
EOF

umask $OLD_UMASK
