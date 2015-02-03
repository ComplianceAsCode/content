#
# Disable httpd.service for all systemd targets
#
systemctl disable httpd.service

#
# Stop httpd.service if currently running
#
systemctl stop httpd.service
