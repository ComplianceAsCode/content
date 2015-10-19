# platform = Red Hat Enterprise Linux 6
#
# Disable nfs for all run levels
#
/sbin/chkconfig --level 0123456 nfs off

#
# Stop nfs if currently running
#
/sbin/service nfs stop
