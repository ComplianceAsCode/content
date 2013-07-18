#
# Disable mdmonitor for all run levels
#
chkconfig --level 0123456 mdmonitor off

#
# Stop mdmonitor if currently running
#
service mdmonitor stop
