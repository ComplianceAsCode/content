#
# Enable netconsole for all run levels
#
chkconfig --level 0123456 netconsole on

#
# Start netconsole if not currently running
#
service netconsole start
