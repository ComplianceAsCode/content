# platform = Red Hat Enterprise Linux 7
grep -qi disable /etc/xinetd.d/bluetooth && \
	sed -i 's/disable.*/disable	= yes/gI' /etc/xinetd.d/bluetooth
#
# Disable bluetooth.service for all systemd targets
#
systemctl disable bluetooth.service

#
# Stop bluetooth.service if currently running
#
systemctl stop bluetooth.service
