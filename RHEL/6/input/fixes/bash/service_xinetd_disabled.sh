#
# Disable xinetd for all run levels
#
/sbin/chkconfig --level 0123456 xinetd off

#
# Stop xinetd if currently running
#
/sbin/service xinetd stop
