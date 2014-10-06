#
# Disable messagebus.service for all systemd targets
#
systemctl disable messagebus.service

#
# Stop messagebus.service if currently running
#
systemctl stop messagebus.service
