# platform = Red Hat Enterprise Linux 7
#
# Disable cgconfig.service for all systemd targets
#
systemctl disable cgconfig.service

#
# Stop cgconfig.service if currently running
#
systemctl stop cgconfig.service
