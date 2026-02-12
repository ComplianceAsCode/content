# platform = multi_platform_all

remote_login_banner_contents=$(echo "(bash-populate remote_login_banner_contents)" | sed 's/\\n/\n/g')
echo "$remote_login_banner_contents" > /etc/issue.net
