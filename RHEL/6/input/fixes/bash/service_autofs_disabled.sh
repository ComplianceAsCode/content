# platform = Red Hat Enterprise Linux 6
#
# Disable autofs for all run levels
#
/sbin/chkconfig --level 0123456 autofs off

#
# Stop autofs if currently running
#
/sbin/service autofs stop
