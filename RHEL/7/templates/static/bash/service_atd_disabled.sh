# platform = Red Hat Enterprise Linux 7
#
# Disable atd.service for all systemd targets
#
systemctl disable atd.service

#
# Stop atd.service if currently running
#
systemctl stop atd.service
