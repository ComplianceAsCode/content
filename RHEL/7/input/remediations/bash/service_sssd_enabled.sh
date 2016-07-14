# platform = Red Hat Enterprise Linux 7
#
# Disable sssd.service for all systemd targets
#
systemctl enable sssd.service

#
# Stop sssd.service if currently running
#
systemctl start sssd.service
