#
# Disable sysstat for all run levels
#
chkconfig --level 0123456 sysstat off

#
# Stop sysstat if currently running
#
service sysstat stop
