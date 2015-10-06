# platform = Red Hat Enterprise Linux 6
#
# Disable acpid for all run levels
#
/sbin/chkconfig --level 0123456 acpid off

#
# Stop acpid if currently running
#
/sbin/service acpid stop
