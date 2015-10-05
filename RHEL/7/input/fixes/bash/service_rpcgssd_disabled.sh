# platform = Red Hat Enterprise Linux 7
#
# Disable nfs-secure.service (rpcgssd) for all systemd targets
#
systemctl disable nfs-secure.service

#
# Stop nfs-secure.service (rpcgssd) if currently running
#
systemctl stop nfs-secure.service
