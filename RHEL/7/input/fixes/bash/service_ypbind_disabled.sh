# platform = Red Hat Enterprise Linux 7
#
# Disable ypbind.service for all systemd targets
#
systemctl disable ypbind.service

#
# Stop ypbind.service if currently running
#
systemctl stop ypbind.service
