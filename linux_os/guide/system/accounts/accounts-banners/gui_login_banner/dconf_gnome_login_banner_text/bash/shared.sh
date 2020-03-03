# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

# Multiple regexes transform the banner regex into a usable banner
# 1 - Keep only the first banners if there are multiple, and remove wrapping regex syntax.
#    (dod_banners contains the long and shor banner)
# 2- Add spaces ' '. (Transforms regex for "space or newline" into a " ")
# 3- Adds newline "tokens". (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "(n)*")
# 4- Remove any leftover backslash. (From any parethesis in the banner, for example).
# 5- Removes the newline "token." (Transforms them into newline escape sequences "\n").
#    ( Needs to be done after 4, otherwise the escapce sequence will become just "n".
expanded=$(echo "$login_banner_text" | sed 's/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\]+/ /g;s/(?:\[\\n\]+|(?:\\n)+)/(n)\*/g;s/\\//g;s/(n)\*/\\n/g;')

{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-text", "'${expanded}'", "gdm.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "banner-message-text", "gdm.d", "00-security-settings-lock") }}}
