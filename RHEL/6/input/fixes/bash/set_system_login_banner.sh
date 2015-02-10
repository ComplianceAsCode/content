source ./templates/support.sh
populate login_banner_text

# There was a regular-expression matching various banners, needs to be expanded
expanded=$(echo "$login_banner_text" | sed 's/\[\\s\\n\][+*]/ /g;s/\\//g;s/[^-]- /\n\n-/g')
formatted=`echo "$expanded" | fold -sw 80`

cat <<EOF >/etc/issue
$formatted
EOF

printf "\n" >> /etc/issue
