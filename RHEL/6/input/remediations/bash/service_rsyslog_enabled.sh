# platform = Red Hat Enterprise Linux 6
#
# Enable rsyslog for all run levels
#
/sbin/chkconfig --level 0123456 rsyslog on

#
# Start rsyslog if not currently running
#
/sbin/service rsyslog start
