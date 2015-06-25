#
# Install chrony package if necessary
#

yum -y install chrony

#
# Enable chronyd service (for current systemd target)
#

systemctl enable chronyd.service

#
# Start chronyd if not currently running
#

systemctl start chronyd.service
