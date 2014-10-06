#
# Disable sshd.service for all systemd targets
#
systemctl disable sshd.service

#
# Stop sshd.service if currently running
#
systemctl stop sshd.service
