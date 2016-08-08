# platform = Red Hat Enterprise Linux 7
#
# Disable sshd.service for all systemd targets
#
systemctl disable sshd.service

#
# Stop sshd.service if currently running
#
systemctl stop sshd.service
