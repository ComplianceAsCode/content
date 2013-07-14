#
# Enable xinetd for all run levels
#
chkconfig --level 0123456 xinetd on

#
# Start xinetd if not currently running
#
service xinetd start
