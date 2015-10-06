# platform = Red Hat Enterprise Linux 7
#
# Disable snmpd.service for all systemd targets
#
systemctl disable snmpd.service

#
# Stop snmpd.service if currently running
#
systemctl stop snmpd.service
