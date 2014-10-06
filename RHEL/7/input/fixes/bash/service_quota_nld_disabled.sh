#
# Disable quota_nld.service for all systemd targets
#
systemctl disable quota_nld.service

#
# Stop quota_nld.service if currently running
#
systemctl stop quota_nld.service
