#
# Disable ypbind for all run levels
#
/sbin/chkconfig --level 0123456 ypbind off

#
# Stop ypbind if currently running
#
/sbin/service ypbind stop 1>/dev/null
