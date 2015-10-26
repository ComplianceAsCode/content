# platform = Red Hat Enterprise Linux 7
#
# Disable avahi-daemon.service for all systemd targets
#
systemctl disable avahi-daemon.service

#
# Stop avahi-daemon.service if currently running
# and disable avahi-daemon.socket so the avahi-daemon.service
# can't be activated
#
systemctl stop avahi-daemon.service
systemctl disable avahi-daemon.socket
