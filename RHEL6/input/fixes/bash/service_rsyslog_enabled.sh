#
# Enable rsyslog for all run levels
#
chkconfig --level 0123456 rsyslog on

#
# Stop rsyslog if currently running
#
service rsyslog start
