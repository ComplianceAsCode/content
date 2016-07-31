# platform = Red Hat Enterprise Linux 7
#
# Disable portreserve.service for all systemd targets
#
systemctl disable portreserve.service

#
# Stop portreserve.service if currently running
#
systemctl stop portreserve.service
