# platform = Red Hat Enterprise Linux 7
#
# Disable nfs-lock.service for all systemd targets
#
systemctl disable nfs-lock.service

#
# Stop nfs-lock.service if currently running
#
systemctl stop nfs-lock.service
