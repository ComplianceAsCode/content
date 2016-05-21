# platform = Red Hat Enterprise Linux 7
#
# Disable named.service for all systemd targets
#
systemctl disable named.service

#
# Stop named.service if currently running
#
systemctl stop named.service
