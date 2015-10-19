# platform = Red Hat Enterprise Linux 7
#
# Disable dovecot.service for all systemd targets
#
systemctl disable dovecot.service

#
# Stop dovecot.service if currently running
#
systemctl stop dovecot.service
