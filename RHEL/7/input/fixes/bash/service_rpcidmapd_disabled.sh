#
# Disable nfs-idmap.service (rpcidmapd) for all systemd targets
#
systemctl disable nfs-idmap.service

#
# Stop nfs-idmap.service (rpcidmapd) if currently running
#
systemctl stop nfs-idmap.service
