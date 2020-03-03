# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate login_banner_text

# Multiple regexes transform the banner regex into a usable banner
# 1 - Keep only the first banners if there are multiple, and remove wrapping regex syntax.
#    (dod_banners contains the long and shor banner)
# 2- Add spaces ' '. (Transforms regex for "space or newline" into a " ")
# 3- Adds newlines. (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "\n")
# 4- Remove any leftover backslash. (From any parethesis in the banner, for example).
expanded=$(echo "$login_banner_text" | sed 's/\^(\(.*\)|.*$/\1/g;s/\[\\s\\n\]+/ /g;s/(?:\[\\n\]+|(?:\\n)+)/\n/g;s/\\//g;')
formatted=$(echo "$expanded" | fold -sw 80)

cat <<EOF >/etc/issue
$formatted
EOF

printf "\n" >> /etc/issue
