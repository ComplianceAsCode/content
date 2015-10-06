# platform = Red Hat Enterprise Linux 6
#
# Disable bluetooth for all run levels
#
/sbin/chkconfig --level 0123456 bluetooth off

#
# Stop bluetooth if currently running
#
/sbin/service bluetooth stop
