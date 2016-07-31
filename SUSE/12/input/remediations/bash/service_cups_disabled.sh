# platform = Red Hat Enterprise Linux 7
#
# Disable cups.service for all systemd targets
#
systemctl disable cups.service

#
# Stop cups.service if currently running
# and disable cups.path and cups.socket so
# cups.service can't be activated
#
systemctl stop cups.service
systemctl disable cups.path
systemctl disable cups.socket
