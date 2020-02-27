# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

# There was a regular-expression matching various banners, needs to be expanded
expanded=$(echo "$login_banner_text" | sed 's/(\\\\\x27)\*/\\\x27/g;s/(\\\x27)\*//g;s/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\]+/ /g;s/\\//g;s/\[n\]+/\n/g')
formatted=$(echo "$expanded" | fold -sw 80)

cat <<EOF >/etc/issue
$formatted
EOF

printf "\n" >> /etc/issue
