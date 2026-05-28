# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

ln -sf /etc/sysctl.conf /etc/sysctl.d/99-sysctl.conf
systemctl restart systemd-sysctl.service
