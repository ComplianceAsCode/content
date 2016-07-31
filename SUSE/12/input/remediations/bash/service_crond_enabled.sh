# platform = Red Hat Enterprise Linux 7
#
# Enable crond.service for all systemd targets
#
systemctl enable crond.service

#
# Start crond.service if not currently running
#
systemctl start crond.service
