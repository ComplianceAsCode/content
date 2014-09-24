#
# Disable xinetd.service for all systemd targets
#
systemctl disable xinetd.service

#
# Stop xinetd.service if currently running
#
systemctl stop xinetd.service
