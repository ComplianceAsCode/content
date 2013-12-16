#
# Disable qpidd for all run levels
#
chkconfig --level 0123456 qpidd off

#
# Stop qpidd if currently running
#
service qpidd stop
