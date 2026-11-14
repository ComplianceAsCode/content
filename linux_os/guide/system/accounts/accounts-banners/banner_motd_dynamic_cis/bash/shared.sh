# platform = multi_platform_debian,multi_platform_ubuntu
# reboot = false
# strategy = disable
# complexity = low
# disruption = low

if [ -x /etc/update-motd.d/10-uname ]; then
    chmod -x /etc/update-motd.d/10-uname
fi
