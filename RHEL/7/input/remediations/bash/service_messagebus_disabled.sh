# platform = Red Hat Enterprise Linux 7
#
# Disable messagebus.service for all systemd targets
#
systemctl disable messagebus.service

#
# Stop messagebus.service if currently running
#
systemctl stop messagebus.service
