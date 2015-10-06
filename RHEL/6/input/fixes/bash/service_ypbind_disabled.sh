# platform = Red Hat Enterprise Linux 6
#
# Disable ypbind for all run levels
#
/sbin/chkconfig --level 0123456 ypbind off

#
# Stop ypbind if currently running
#
/sbin/service ypbind stop
