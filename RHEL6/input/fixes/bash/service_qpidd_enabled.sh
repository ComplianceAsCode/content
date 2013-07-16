#
# Enable qpidd for all run levels
#
chkconfig --level 0123456 qpidd on

#
# Start qpidd if not currently running
#
service qpidd start
