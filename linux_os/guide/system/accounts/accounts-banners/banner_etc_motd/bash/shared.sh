# platform = multi_platform_all

motd_banner_contents=$(echo "(bash-populate motd_banner_contents)" | sed 's/\\n/\n/g')
echo "$motd_banner_contents" > /etc/motd
