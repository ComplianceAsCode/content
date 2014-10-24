#
# Disable messagebus for all run levels
#
/sbin/chkconfig --level 0123456 messagebus off

#
# Stop messagebus if currently running
#
/sbin/service messagebus stop
