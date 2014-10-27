#
# Disable sysstat for all run levels
#
/sbin/chkconfig --level 0123456 sysstat off

#
# Stop sysstat if currently running
#
/sbin/service sysstat stop
