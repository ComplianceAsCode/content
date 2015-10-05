# platform = Red Hat Enterprise Linux 6
#
# Disable tftp for all run levels
#
/sbin/chkconfig --level 0123456 tftp off

#
# Stop tftp if currently running
#
/sbin/service tftp stop
