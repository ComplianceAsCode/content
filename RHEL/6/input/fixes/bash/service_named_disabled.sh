#
# Disable named for all run levels
#
/sbin/chkconfig --level 0123456 named off

#
# Stop named if currently running
#
/sbin/service named stop
