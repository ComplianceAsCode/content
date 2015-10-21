# platform = Red Hat Enterprise Linux 7
#
# Disable oddjobd.service for all systemd targets
#
systemctl disable oddjobd.service

#
# Stop oddjobd.service if currently running
#
systemctl stop oddjobd.service
