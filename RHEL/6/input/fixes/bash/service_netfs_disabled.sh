#
# Disable netfs for all run levels
#
/sbin/chkconfig --level 0123456 netfs off

#
# Stop netfs if currently running
#
/sbin/service netfs stop
