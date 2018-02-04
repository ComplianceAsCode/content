# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

expanded=$(echo "$login_banner_text" | sed 's/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\][+*]/ /g;s/\\//g;s/(n)\*/\\n/g')

cat <<EOF >/etc/dconf/db/gdm.d/00-security-settings
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text=string '$expanded'
EOF
