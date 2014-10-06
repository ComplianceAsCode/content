#
# Enable ip6tables.service for all systemd targets
#
systemctl enable ip6tables.service

#
# Start ip6tables.service if not currently running
#
systemctl start ip6tables.service
