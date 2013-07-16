#
# Enable tftp for all run levels
#
chkconfig --level 0123456 tftp on

#
# Start tftp if not currently running
#
service tftp start
