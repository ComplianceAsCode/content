# platform = Red Hat Enterprise Linux 6
#
# Disable certmonger for all run levels
#
/sbin/chkconfig --level 0123456 certmonger off

#
# Stop certmonger if currently running
#
/sbin/service certmonger stop
