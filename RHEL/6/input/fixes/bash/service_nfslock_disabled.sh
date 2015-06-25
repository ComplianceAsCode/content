#
# Disable nfslock for all run levels
#
/sbin/chkconfig --level 0123456 nfslock off

#
# Stop nfslock if currently running
#
/sbin/service nfslock stop
