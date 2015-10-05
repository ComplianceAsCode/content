# platform = Red Hat Enterprise Linux 7
#
# Disable rhsmcertd.service for all systemd targets
#
systemctl disable rhsmcertd.service

#
# Stop rhsmcertd.service if currently running
#
systemctl stop rhsmcertd.service
