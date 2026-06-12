# platform = multi_platform_ubuntu,multi_platform_debian

systemctl unmask ufw.service
systemctl --now enable ufw.service
ufw --force enable
