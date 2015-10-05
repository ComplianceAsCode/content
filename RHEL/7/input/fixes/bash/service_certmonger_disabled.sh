# platform = Red Hat Enterprise Linux 7
#
# Disable certmonger.service for all systemd targets
#
systemctl disable certmonger.service

#
# Stop certmonger.service if currently running
#
systemctl stop certmonger.service
