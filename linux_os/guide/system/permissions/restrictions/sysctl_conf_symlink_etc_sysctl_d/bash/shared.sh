# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

[ -f /etc/sysctl.conf ] || install -m 0644 /dev/null /etc/sysctl.conf
ln -sf /etc/sysctl.conf /etc/sysctl.d/99-sysctl.conf
systemctl restart systemd-sysctl.service
