# platform = Red Hat Enterprise Linux 7
#
# Enable postfix.service for all systemd targets
#
systemctl enable postfix.service

#
# Start postfix.service if not currently running
#
systemctl start postfix.service
