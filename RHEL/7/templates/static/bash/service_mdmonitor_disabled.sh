# platform = Red Hat Enterprise Linux 7
#
# Disable mdmonitor.service for all systemd targets
#
systemctl disable mdmonitor.service

#
# Stop mdmonitor.service if currently running
#
systemctl stop mdmonitor.service
