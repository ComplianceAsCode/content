#
# Enable ntpd for all run levels
#
chkconfig --level 0123456 ntpd on

#
# Start ntpd if not currently running
#
service ntpd start
