# platform = multi_platform_debian
# reboot = false
# strategy = disable
# complexity = low
# disruption = low

if [ -x /etc/update-motd.d/10-uname ]; then
    chmod a-x /etc/update-motd.d/10-uname
fi
