# platform = Red Hat Enterprise Linux 7
#
# Disable zebra.service for all systemd targets
#
systemctl disable zebra.service

#
# Stop zebra.service if currently running
#
systemctl stop zebra.service
