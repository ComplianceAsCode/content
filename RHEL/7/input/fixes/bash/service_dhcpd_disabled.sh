#
# Disable dhcpd.service for all systemd targets
#
systemctl disable dhcpd.service

#
# Stop dhcpd.service if currently running
#
systemctl stop dhcpd.service
