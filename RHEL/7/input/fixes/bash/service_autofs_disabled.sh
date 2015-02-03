#
# Disable autofs.service for all systemd targets
#
systemctl disable autofs.service

#
# Stop autofs.service if currently running
#
systemctl stop autofs.service
