#
# Disable atd for all run levels
#
/sbin/chkconfig --level 0123456 atd off

#
# Stop atd if currently running
#
/sbin/service atd stop
