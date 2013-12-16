#
# Disable saslauthd for all run levels
#
chkconfig --level 0123456 saslauthd off

#
# Stop saslauthd if currently running
#
service saslauthd stop
