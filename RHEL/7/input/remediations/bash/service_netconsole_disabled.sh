# platform = Red Hat Enterprise Linux 7
#
# Disable netconsole for all run levels
#
chkconfig --level 0123456 netconsole off

#
# Stop netconsole if currently running
#
service netconsole stop
