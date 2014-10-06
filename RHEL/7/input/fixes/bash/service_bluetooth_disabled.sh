#
# Disable bluetooth.service for all systemd targets
#
systemctl disable bluetooth.service

#
# Stop bluetooth.service if currently running
#
systemctl stop bluetooth.service
