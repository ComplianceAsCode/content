# platform = Red Hat Enterprise Linux 7
#. /usr/share/scap-security-guide/remediation_functions
populate dconf_banner_text
# There was a regular-expression matching various banners, needs to be expanded
# When there are multiple banners in dconf_banner_text, the first banner should be the one for RHEL7
expanded=$(echo "$dconf_banner_text" | sed 's/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\][+*]/ /g;s/\\//g;s/nn\*-/\\n\\n-/g')

cat <<EOF >/etc/dconf/db/gdm.d/00-security-settings
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text=string '$expanded'
EOF
