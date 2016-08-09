# platform = Red Hat Enterprise Linux 7
#
# Disable nfs.service for all systemd targets
#
systemctl disable nfs.service

#
# Stop nfs.service if currently running
#
systemctl stop nfs.service
