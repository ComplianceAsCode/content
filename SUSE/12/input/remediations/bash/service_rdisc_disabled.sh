# platform = Red Hat Enterprise Linux 7
#
# Disable rdisc.service for all systemd targets
#
systemctl disable rdisc.service

#
# Stop rdisc.service if currently running
#
systemctl stop rdisc.service
