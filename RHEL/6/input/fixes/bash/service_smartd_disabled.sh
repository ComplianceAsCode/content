#
# Disable smartd for all run levels
#
/sbin/chkconfig --level 0123456 smartd off

#
# Stop smartd if currently running
#
/sbin/service smartd stop
