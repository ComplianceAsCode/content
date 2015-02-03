source ./templates/support.sh
populate login_banner_text

# There was a regular-expression matching various banners, needs to be expanded
expanded=$(echo "$login_banner_text" | sed 's/\[\\s\\n\][*+]/ /g;s/\\//g;')

cat <<EOF >/etc/issue
$expanded
EOF
