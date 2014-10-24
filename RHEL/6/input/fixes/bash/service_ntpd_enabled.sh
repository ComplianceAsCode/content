#
# Enable ntpd for all run levels
#
/sbin/chkconfig --level 0123456 ntpd on

#
# Start ntpd if not currently running
#
/sbin/service ntpd start
