#
# Disable qpidd for all run levels
#
/sbin/chkconfig --level 0123456 qpidd off

#
# Stop qpidd if currently running
#
/sbin/service qpidd stop
