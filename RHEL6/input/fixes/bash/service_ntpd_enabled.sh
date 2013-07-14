#
# Enable ntpd for all run levels
#
chkconfig --level 0123456 ntpd on

#
# Stop ntpd if currently running
#
service ntpd start
