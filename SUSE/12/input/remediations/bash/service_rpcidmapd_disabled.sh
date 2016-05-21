# platform = Red Hat Enterprise Linux 7
#
# Disable nfs-idmap.service (rpcidmapd) for all systemd targets
#
systemctl disable nfs-idmap.service

#
# Stop nfs-idmap.service (rpcidmapd) if currently running
#
systemctl stop nfs-idmap.service
