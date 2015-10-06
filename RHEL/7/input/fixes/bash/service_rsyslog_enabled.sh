# platform = Red Hat Enterprise Linux 7
#
# Enable rsyslog.service for all systemd targets
#
systemctl enable rsyslog.service

#
# Start rsyslog.service if not currently running
#
systemctl start rsyslog.service
