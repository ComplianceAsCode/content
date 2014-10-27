#
# Disable netconsole for all run levels
#
/sbin/chkconfig --level 0123456 netconsole off

#
# Stop netconsole if currently running
#
/sbin/service netconsole stop
