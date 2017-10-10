# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

# There was a regular-expression matching various banners, needs to be expanded
# When there are multiple banners in login_banner_text, the first banner should be the one for RHEL7
expanded=$(echo "$login_banner_text" | sed 's/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\][+*]/ /g;s/\\//g;s/[^-]- /\n\n-/g')
formatted=$(echo "$expanded" | fold -sw 80)

cat <<EOF >/etc/issue
$formatted
EOF

printf "\n" >> /etc/issue
