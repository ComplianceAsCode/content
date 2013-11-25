#
# Install ntp package if necessary
#

yum -y install ntp

#
# Enable ntpd service (for current systemd target)
#

systemctl enable ntpd.service

#
# Start ntpd if not currently running
#

systemctl start ntpd.service
