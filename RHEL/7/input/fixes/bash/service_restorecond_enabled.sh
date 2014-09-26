#
# Enable restorecond.service for all systemd targets
#
systemctl enable restorecond.service

#
# Start restorecond.service if not currently running
#
systemctl start restorecond.service
