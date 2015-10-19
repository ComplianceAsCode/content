# platform = Red Hat Enterprise Linux 6
#
# Disable rhnsd for all run levels
#
/sbin/chkconfig --level 0123456 rhnsd off

#
# Stop rhnsd if currently running
#
/sbin/service rhnsd stop
