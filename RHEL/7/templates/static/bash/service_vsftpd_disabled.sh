# platform = Red Hat Enterprise Linux 7
#
# Disable vsftpd.service for all systemd targets
#
systemctl disable vsftpd.service

#
# Stop vsftpd.service if currently running
#
systemctl stop vsftpd.service
