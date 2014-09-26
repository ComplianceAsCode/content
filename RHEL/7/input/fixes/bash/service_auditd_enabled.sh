#
# Enable auditd.service for all systemd targets
#
systemctl enable auditd.service

#
# Start auditd.service if not currently running
#
systemctl start auditd.service
