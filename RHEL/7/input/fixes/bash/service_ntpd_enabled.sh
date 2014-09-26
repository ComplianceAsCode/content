#
# Enable ntpd.service for all systemd targets
#
systemctl enable ntpd.service

#
# Start ntpd.service if not currently running
#
systemctl start ntpd.service
