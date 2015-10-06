# platform = Red Hat Enterprise Linux 7
#
# Disable nfs-secure-server.service (rpcsvcgssd) for all systemd targets
#
systemctl disable nfs-secure-server.service

#
# Stop nfs-secure-server.service (rpcsvcgssd) if currently running
#
systemctl stop nfs-secure-server.service
