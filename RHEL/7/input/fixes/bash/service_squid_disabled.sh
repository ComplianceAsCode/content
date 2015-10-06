# platform = Red Hat Enterprise Linux 7
#
# Disable squid.service for all systemd targets
#
systemctl disable squid.service

#
# Stop squid.service if currently running
#
systemctl stop squid.service
