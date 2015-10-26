# platform = Red Hat Enterprise Linux 7
#
# Disable qpidd.service for all systemd targets
#
systemctl disable qpidd.service

#
# Stop qpidd.service if currently running
#
systemctl stop qpidd.service
