#
# Disable saslauthd for all run levels
#
/sbin/chkconfig --level 0123456 saslauthd off

#
# Stop saslauthd if currently running
#
/sbin/service saslauthd stop
