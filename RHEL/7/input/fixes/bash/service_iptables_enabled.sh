#
# Enable iptables.service for all systemd targets
#
systemctl enable iptables.service

#
# Start iptables.service if not currently running
#
systemctl start iptables.service
