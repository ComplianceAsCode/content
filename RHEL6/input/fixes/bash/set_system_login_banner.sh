source ./templates/support.sh
populate login_banner_text

cat <<EOF >/etc/issue
$login_banner_text
EOF
