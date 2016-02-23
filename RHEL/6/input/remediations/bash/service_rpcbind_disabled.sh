# platform = Red Hat Enterprise Linux 6
#
# Disable rpcbind for all run levels
#
/sbin/chkconfig --level 0123456 rpcbind off

#
# Stop rpcbind if currently running
#
/sbin/service rpcbind stop
