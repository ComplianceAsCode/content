#
# Disable abrtd.service for all systemd targets
#
systemctl disable abrtd.service

#
# Stop abrtd.service if currently running
#
systemctl stop abrtd.service
