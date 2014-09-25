#
# Disable saslauthd.service for all systemd targets
#
systemctl disable saslauthd.service

#
# Stop saslauthd.service if currently running
#
systemctl stop saslauthd.service
