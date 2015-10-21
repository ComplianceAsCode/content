# platform = Red Hat Enterprise Linux 6
#
# Disable rpcsvcgssd for all run levels
#
/sbin/chkconfig --level 0123456 rpcsvcgssd off

#
# Stop rpcsvcgssd if currently running
#
/sbin/service rpcsvcgssd stop
