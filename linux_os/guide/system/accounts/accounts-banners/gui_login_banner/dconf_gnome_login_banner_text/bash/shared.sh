# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

expanded=$(echo "$login_banner_text" | sed 's/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\]+/ /g;s/(?:\[\\n\]+|(?:\\n)+)/(n)\*/g;s/\\//g;s/(n)\*/\\n/g;')

{{{ bash_dconf_settings("org/gnome/login-screen", "banner-message-text", "'${expanded}'", "gdm.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/login-screen", "banner-message-text", "gdm.d", "00-security-settings-lock") }}}
