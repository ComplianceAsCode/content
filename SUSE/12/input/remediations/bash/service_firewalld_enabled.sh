# platform = Red Hat Enterprise Linux 7
#
# Enable firewalld.service for all systemd targets
#
systemctl enable firewalld.service

#
# Start firewalld.service if not currently running
#
systemctl start firewalld.service
