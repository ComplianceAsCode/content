# platform = Red Hat Enterprise Linux 7
#
# Disable kdump.service for all systemd targets
#
systemctl disable kdump.service

#
# Stop kdump.service if currently running
#
systemctl stop kdump.service
