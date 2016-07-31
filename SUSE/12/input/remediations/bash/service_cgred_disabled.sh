# platform = Red Hat Enterprise Linux 7
#
# Disable cgred.service for all systemd targets
#
systemctl disable cgred.service

#
# Stop cgred.service if currently running
#
systemctl stop cgred.service
