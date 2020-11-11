# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

if ! grep -P "^(?!#)[\s]*Defaults.*[\s]+noexec[\s]*.*$" /etc/sudoers; then
    echo "Defaults noexec" >> /etc/sudoers
    /usr/sbin/visudo -cf $f &> /dev/null || echo "Fail to validate $f with visudo"
fi
