# platform = Red Hat Enterprise Linux 7
#
# Disable sysstat.service for all systemd targets
#
systemctl disable sysstat.service

#
# Stop sysstat.service if currently running
#
systemctl stop sysstat.service
