#
# Disable mdmonitor for all run levels
#
/sbin/chkconfig --level 0123456 mdmonitor off

#
# Stop mdmonitor if currently running
#
/sbin/service mdmonitor stop
