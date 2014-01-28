#
# Enable rsyslog for all run levels
#
chkconfig --level 0123456 rsyslog on

#
# Start rsyslog if not currently running
#
service rsyslog start
