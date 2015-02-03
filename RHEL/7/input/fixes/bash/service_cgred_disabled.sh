#
# Disable cgred.service for all systemd targets
#
systemctl disable cgred.service

#
# Stop cgred.service if currently running
#
systemctl stop cgred.service
