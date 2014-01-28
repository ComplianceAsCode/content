#
# Disable messagebus for all run levels
#
chkconfig --level 0123456 messagebus off

#
# Stop messagebus if currently running
#
service messagebus stop
