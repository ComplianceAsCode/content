#
# Disable nfs.service for all systemd targets
#
systemctl disable nfs.service

#
# Stop nfs.service if currently running
#
systemctl stop nfs.service
