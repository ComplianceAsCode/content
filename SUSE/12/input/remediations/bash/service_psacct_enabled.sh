# platform = SUSE Enterprise 12
#
# Enable psacct.service for all systemd targets
#
systemctl enable psacct.service

#
# Start psacct.service if not currently running
#
systemctl start psacct.service
